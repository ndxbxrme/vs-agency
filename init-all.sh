#!/bin/bash
git pull
npm install
bower install
. env.sh
grunt build
screen -X -S VSAGENCY quit
screen -S VSAGENCY node server/app.js --expose-gc
