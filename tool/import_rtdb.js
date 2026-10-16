const fs = require('fs');

const maxChunkBytes = 8 * 1024 * 1024;
const concurrency = 8;

function skipWs(buf, i) {
  while (i < buf.length && buf[i] <= 0x20) i++;
  return i;
}

function readString(buf, i) {
  if (buf[i] !== 0x22) throw new Error(`Expected string at ${i}`);
  let j = i + 1;
  while (j < buf.length) {
    if (buf[j] === 0x5c) {
      j += 2;
      continue;
    }
    if (buf[j] === 0x22) return j + 1;
    j++;
  }
  throw new Error('Unterminated string');
}

function skipContainer(buf, i) {
  let depth = 0;
  do {
    const c = buf[i];
    if (c === 0x22) {
      i = readString(buf, i);
      continue;
    }
    if (c === 0x7b || c === 0x5b) depth++;
    else if (c === 0x7d || c === 0x5d) depth--;
    i++;
  } while (depth);
  return i;
}

function skipValue(buf, i) {
  const c = buf[i];
  if (c === 0x22) return readString(buf, i);
  if (c === 0x7b || c === 0x5b) return skipContainer(buf, i);
  while (i < buf.length) {
    const d = buf[i];
    if (d === 0x2c || d === 0x7d || d === 0x5d || d <= 0x20) break;
    i++;
  }
  return i;
}

function topLevelFields(buf) {
  let i = skipWs(buf, 0);
  if (buf[i++] !== 0x7b) throw new Error('Expected object');
  const fields = [];
  while (i < buf.length) {
    i = skipWs(buf, i);
    if (buf[i] === 0x7d) break;
    if (buf[i] === 0x2c) {
      i++;
      continue;
    }
    const keyStart = i;
    i = readString(buf, i);
    const key = JSON.parse(buf.toString('utf8', keyStart, i));
    i = skipWs(buf, i);
    if (buf[i++] !== 0x3a) throw new Error(`Expected colon after ${key}`);
    i = skipWs(buf, i);
    const start = i;
    i = skipValue(buf, i);
    fields.push({ key, start, end: i });
  }
  return fields;
}

function objectEntries(buf, start, end) {
  if (buf[start] !== 0x7b) throw new Error('Expected object value');
  let i = start + 1;
  const entries = [];
  while (i < end) {
    i = skipWs(buf, i);
    if (i >= end || buf[i] === 0x7d) break;
    if (buf[i] === 0x2c) {
      i++;
      continue;
    }
    const entryStart = i;
    i = readString(buf, i);
    i = skipWs(buf, i);
    if (buf[i++] !== 0x3a) throw new Error('Expected colon');
    i = skipWs(buf, i);
    i = skipValue(buf, i);
    entries.push(buf.subarray(entryStart, i));
  }
  return entries;
}

function chunkEntries(entries, maxBytes) {
  const chunks = [];
  let group = [];
  let size = 2;
  const flush = () => {
    if (!group.length) return;
    const parts = [Buffer.from('{')];
    for (let i = 0; i < group.length; i++) {
      if (i) parts.push(Buffer.from(','));
      parts.push(group[i]);
    }
    parts.push(Buffer.from('}'));
    chunks.push(Buffer.concat(parts));
    group = [];
    size = 2;
  };
  for (const entry of entries) {
    const extra = entry.length + (group.length ? 1 : 0);
    if (group.length && size + extra > maxBytes) flush();
    group.push(entry);
    size += extra;
  }
  flush();
  return chunks;
}

async function runPool(items, limit, fn) {
  let next = 0;
  async function worker() {
    while (next < items.length) {
      const index = next++;
      await fn(items[index], index);
    }
  }
  const workers = Math.min(limit, items.length);
  await Promise.all(Array.from({ length: workers }, () => worker()));
}

async function importDatabase(file, send, options = {}) {
  const maxBytes = options.maxChunkBytes ?? maxChunkBytes;
  const workers = options.concurrency ?? concurrency;
  const buf = Buffer.isBuffer(file) ? file : fs.readFileSync(file);
  const fields = topLevelFields(buf);
  const puts = [];
  let stats = null;
  for (const field of fields) {
    const body = buf.subarray(field.start, field.end);
    if (field.key === 'stats') stats = body;
    else puts.push([field.key, body]);
  }

  const statChunks = stats ? chunkEntries(objectEntries(stats, 0, stats.length), maxBytes) : [];

  let uploaded = 0;
  await Promise.all([
    ...puts.map(async ([key, body]) => {
      await send('PUT', key, body);
      console.log(`PUT ${key} ${body.length}`);
    }),
    (async () => {
      if (!stats) return;
      await send('DELETE', 'stats');
      console.log(`DELETE stats (${statChunks.length} chunks)`);
      await runPool(statChunks, workers, async (body) => {
        await send('PATCH', 'stats', body);
        uploaded++;
        if (uploaded % 10 === 0 || uploaded === statChunks.length) {
          console.log(`stats ${uploaded}/${statChunks.length}`);
        }
      });
    })(),
  ]);
}

async function main() {
  const file = process.argv[2];
  if (!file) {
    console.error('Usage: node tool/import_rtdb.js <rtdb.json>');
    process.exit(1);
  }
  const base = 'http://127.0.0.1:9000';
  const ns = 'pub-stats-collector-default-rtdb';

  async function send(method, node, body) {
    const url = `${base}/${encodeURIComponent(node)}.json?ns=${ns}&disableTriggers=true&writeSizeLimit=unlimited`;
    for (let attempt = 1; attempt <= 4; attempt++) {
      try {
        const response = await fetch(url, {
          method,
          headers: {
            Authorization: 'Bearer owner',
            'Content-Type': 'application/json',
          },
          body,
        });
        if (!response.ok) {
          const text = await response.text();
          throw new Error(`${response.status} ${text.slice(0, 240)}`);
        }
        return;
      } catch (error) {
        if (attempt === 4) throw new Error(`${method} ${node}: ${error.message}`);
        console.log(`retry ${method} ${node} (${attempt}) ${error.message}`);
        await new Promise((resolve) => setTimeout(resolve, 500 * attempt));
      }
    }
  }

  const started = Date.now();
  await importDatabase(file, send);
  console.log(`IMPORT_DONE ${((Date.now() - started) / 1000).toFixed(1)}s`);
}

if (require.main === module) {
  main().catch((error) => {
    console.error(error);
    process.exit(1);
  });
}

module.exports = { importDatabase };
