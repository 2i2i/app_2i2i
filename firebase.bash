#!/bin/bash

flutter build web

# run the original firebase
if [ $FIREBASE_TOKEN ]; then
  firebase "$@" --token $FIREBASE_TOKEN
else
  firebase "$@"
fi
