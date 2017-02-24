#!/bin/bash
git pull
npm install
npm install -g grunt-cli
bower install
. env.sh
grunt build
screen -X -S VSAGENCY quit
screen -S VSAGENCY node --expose-gc server/app.js
