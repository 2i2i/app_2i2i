#!/bin/bash

pwd
ls

flutter build web
firebase deploy --only hosting --token $FIREBASE_TOKEN