#!/bin/sh
set -e

if ! command -v jp; then
  sudo wget https://github.com/jmespath/jp/releases/download/0.2.1/jp-linux-amd64 \
    -O /usr/local/bin/jp 1> /dev/null  2>&1 &&
    sudo chmod +x /usr/local/bin/jp 1> /dev/null 2>&1
fi
