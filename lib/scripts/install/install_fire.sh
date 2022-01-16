#!/bin/sh
set -e

if ! command -v fire; then
  if [ ! -d "$HOME/.fire" ]; then
    mkdir "$HOME/.fire" 1> /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo "Could not create directory: $HOME/.fire"
      exit 1
    fi
  fi
  git clone --quiet https://github.com/hwcharlton/fire.git "$HOME/.fire/fire" 1> /dev/null 2>&1
  sudo ln -s "$HOME/.fire/fire/bin/fire" /usr/local/bin/fire 1>/dev/null 2>&1
fi
