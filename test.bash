#!/bin/bash

echo A
echo $FIREBASE_TOKEN
echo B

# run the original firebase
# if [ $FIREBASE_TOKEN ]; then
#   firebase "$@" --token $FIREBASE_TOKEN
# else
#   firebase "$@"
# fi