#!/bin/zsh

# DEATH TO ALL
lsof -t -i tcp:9099 | xargs kill
lsof -t -i tcp:9000 | xargs kill
lsof -t -i tcp:5143 | xargs kill

cd functions
dart run tool/build.dart
cd ..

if [[ ! -f emcache/rtdb.json ]]; then
  echo 'emcache/rtdb.json is missing'
  exit 1
fi

# The database export is larger than the emulator's 256MB request limit, so
# --import cannot load it. Import the file in pieces once the database is up.
# --export-on-exit would replace this file with "Payload is too large".
firebase emulators:start --inspect-functions --import=emcache &
emu=$!
trap 'kill -INT $emu 2>/dev/null; wait $emu; exit 130' INT TERM

ready=0
for _ in {1..180}; do
  if ! kill -0 $emu 2>/dev/null; then
    wait $emu
    exit $?
  fi
  if curl -sf -o /dev/null --max-time 1 -H 'Authorization: Bearer owner' 'http://127.0.0.1:9000/.json?ns=pub-stats-collector-default-rtdb'; then
    ready=1
    break
  fi
  sleep 0.5
done
if (( ready == 0 )); then
  echo 'Database emulator did not start'
  kill -INT $emu 2>/dev/null
  wait $emu
  exit 1
fi

node tool/import_rtdb.js emcache/rtdb.json || {
  status=$?
  kill -INT $emu 2>/dev/null
  wait $emu
  exit $status
}

wait $emu
