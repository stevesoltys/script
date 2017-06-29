#!/bin/bash

[[ $# -eq 4 ]] || exit 1

for device in angler bullhead marlin sailfish; do
  for old in $2 $3 $4; do
    script/generate_delta.sh $device $old $1
  done
done
