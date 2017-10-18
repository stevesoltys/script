#!/bin/bash

if [[ $# -ne 1 ]]; then
  exit 1
fi

build_id=$1

vendor/android-prepare-vendor/execute-all.sh -d sailfish -b ${build_id} -o vendor/android-prepare-vendor
mkdir -p vendor/google_devices

rm -rf vendor/google_devices/sailfish
mv vendor/android-prepare-vendor/sailfish/${build_id,,}/vendor/google_devices/sailfish vendor/google_devices

rm -rf vendor/google_devices/marlin
mv vendor/android-prepare-vendor/sailfish/${build_id,,}/vendor/google_devices/marlin vendor/google_devices