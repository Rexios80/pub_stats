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

# --import restores the saved auth users. The database export is too big for
# that, and --export-on-exit would replace it with an error.
firebase emulators:start --inspect-functions --import=emcache &
pid=$!
node tool/import_rtdb.js emcache/rtdb.json || kill $pid
wait $pid
