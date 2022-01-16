#!/bin/sh
set -e

if ! command -v git; then
  sudo yum -q -y install git 1> /dev/null 2>&1
fi
