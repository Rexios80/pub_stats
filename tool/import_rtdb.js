const fs = require('fs');

const base = 'http://127.0.0.1:9000';
const ns = 'pub-stats-collector-default-rtdb';
const chunkBytes = 8 * 1024 * 1024;
const concurrency = 8;

function ws(buf, i) {
  while (buf[i] <= 0x20) i++;
  return i;
}

// Skip one JSON value. Returns the index just after it.
function skip(buf, i) {
  if (buf[i] === 0x22) {
    while (++i < buf.length) {
      if (buf[i] === 0x5c) i++;
      else if (buf[i] === 0x22) return i + 1;
    }
    throw new Error('Unterminated string');
  }
  if (buf[i] !== 0x7b && buf[i] !== 0x5b) {
    while (buf[i] > 0x20 && buf[i] !== 0x2c && buf[i] !== 0x7d && buf[i] !== 0x5d) i++;
    return i;
  }
  let depth = 1;
  for (i++; i < buf.length; i++) {
    if (buf[i] === 0x22) i = skip(buf, i) - 1;
    else if (buf[i] === 0x7b || buf[i] === 0x5b) depth++;
    else if ((buf[i] === 0x7d || buf[i] === 0x5d) && --depth === 0) return i + 1;
  }
  throw new Error('Unterminated value');
}

function fields(buf) {
  const out = [];
  let i = ws(buf, 0) + 1;
  for (;;) {
    i = ws(buf, i);
    if (buf[i] === 0x7d) return out;
    if (buf[i] === 0x2c) {
      i++;
      continue;
    }
    const keyAt = i;
    i = skip(buf, i);
    const key = JSON.parse(buf.toString('utf8', keyAt, i));
    i = ws(buf, i) + 1;
    const start = i = ws(buf, i);
    i = skip(buf, i);
    out.push([key, buf.subarray(start, i)]);
  }
}

function statChunks(buf) {
  const chunks = [];
  let group = [];
  let size = 2;
  const flush = () => {
    if (!group.length) return;
    const parts = [Buffer.from('{')];
    for (let n = 0; n < group.length; n++) {
      if (n) parts.push(Buffer.from(','));
      parts.push(group[n]);
    }
    parts.push(Buffer.from('}'));
    chunks.push(Buffer.concat(parts));
    group = [];
    size = 2;
  };

  let i = 1;
  while (i < buf.length) {
    i = ws(buf, i);
    if (buf[i] === 0x7d) break;
    if (buf[i] === 0x2c) {
      i++;
      continue;
    }
    const start = i;
    i = skip(buf, i);
    i = ws(buf, i) + 1;
    i = skip(buf, ws(buf, i));
    const entry = buf.subarray(start, i);
    if (group.length && size + entry.length + 1 > chunkBytes) flush();
    group.push(entry);
    size += entry.length + 1;
  }
  flush();
  return chunks;
}

async function send(method, node, body) {
  const url = `${base}/${node}.json?ns=${ns}&disableTriggers=true&writeSizeLimit=unlimited`;
  let error;
  for (let attempt = 0; attempt < 4; attempt++) {
    try {
      const response = await fetch(url, {
        method,
        headers: { Authorization: 'Bearer owner', 'Content-Type': 'application/json' },
        body,
      });
      if (response.ok) return;
      error = new Error(`${method} ${node} ${response.status} ${(await response.text()).slice(0, 200)}`);
    } catch (cause) {
      error = cause;
    }
    await new Promise((resolve) => setTimeout(resolve, 500 * attempt));
  }
  throw error;
}

async function pool(items, fn) {
  let next = 0;
  await Promise.all(
    Array.from({ length: Math.min(concurrency, items.length) }, async () => {
      while (next < items.length) await fn(items[next++]);
    }),
  );
}

async function main() {
  const file = process.argv[2];
  if (!file) throw new Error('Usage: node tool/import_rtdb.js <rtdb.json>');

  const deadline = Date.now() + 90_000;
  for (;;) {
    try {
      const response = await fetch(`${base}/.json?ns=${ns}&shallow=true`, {
        headers: { Authorization: 'Bearer owner' },
      });
      if (response.ok) break;
    } catch {
      // Emulator is still starting.
    }
    if (Date.now() > deadline) throw new Error('Database emulator did not start');
    await new Promise((resolve) => setTimeout(resolve, 500));
  }

  const nodes = fields(fs.readFileSync(file));
  const stats = nodes.find(([key]) => key === 'stats')?.[1];
  await Promise.all(
    nodes.filter(([key]) => key !== 'stats').map(([key, body]) => send('PUT', key, body)),
  );
  if (!stats) return;
  await send('DELETE', 'stats');
  const chunks = statChunks(stats);
  console.log(`stats ${chunks.length}`);
  await pool(chunks, (body) => send('PATCH', 'stats', body));
  console.log('IMPORT_DONE');
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
