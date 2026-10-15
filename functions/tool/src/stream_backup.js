const fs = require('node:fs');
const { chain } = require('stream-chain');
const { parser } = require('stream-json');
const { pick } = require('stream-json/filters/pick.js');
const { streamObject } = require('stream-json/streamers/stream-object.js');
const { Assembler } = require('stream-json/assembler.js');

// Stream each entry under a top-level object key with bounded concurrency.
// `fn` receives (key, value) and may return a Promise.
async function forEachObjectEntry(file, path, fn, concurrency = 10) {
  const pipeline = chain([
    fs.createReadStream(file),
    parser(),
    pick({ filter: path }),
    streamObject(),
  ]);

  const iterator = pipeline[Symbol.asyncIterator]();

  async function worker() {
    for (;;) {
      const { value, done } = await iterator.next();
      if (done) return;
      await fn(value.key, value.value);
    }
  }

  await Promise.all(
    Array.from({ length: concurrency }, () => worker()),
  );
}

// Read a single top-level value without loading the whole backup file.
function readPath(file, path) {
  return new Promise((resolve, reject) => {
    const pipeline = chain([
      fs.createReadStream(file),
      parser(),
      pick({ filter: path }),
    ]);
    const asm = Assembler.connectTo(pipeline);
    asm.onDone((assembler) => resolve(assembler.current));
    pipeline.on('error', reject);
  });
}

module.exports = { forEachObjectEntry, readPath };
