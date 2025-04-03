#!/bin/zsh

# DEATH TO ALL
lsof -t -i tcp:9099 | xargs kill
lsof -t -i tcp:9000 | xargs kill
lsof -t -i tcp:5143 | xargs kill

cd functions
dart run tool/build.dart
cd ..

firebase emulators:start --inspect-functions --export-on-exit=emcache --import=emcache