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

# rtdb.json is too big for --import, and --export-on-exit replaces it with an error.
firebase emulators:start --inspect-functions &
pid=$!
node tool/import_rtdb.js emcache/rtdb.json || kill $pid
wait $pid
