#!/bin/bash

if [[ $# -ne 1 ]]; then
  exit 1
fi

branch=$1
repo init -u https://github.com/stevesoltys/platform_manifest.git -b $branch