#!/bin/bash

set -o nounset

DELETE_TAG=

build_number=
if [[ $# -eq 1 ]]; then
  build_number=$1
elif [[ $# -ne 0 ]]; then
  exit 1
fi

kernel_suffix=oreo-r3
branch=oreo-r3-release
aosp_version=OPR3.170623.008
aosp_tag=android-8.0.0_r15

aosp_forks=(
  device_common
  device_google_marlin
  device_huawei_angler
  device_lge_bullhead
  device_linaro_hikey
  platform_art
  platform_bionic
  platform_bootable_recovery
  platform_build
  platform_build_kati
  platform_build_soong
  platform_external_clang
  platform_external_conscrypt
  platform_external_llvm
  platform_external_nanopb-c
  platform_external_svox
  platform_external_sqlite
  platform_external_v8
  platform_external_wpa_supplicant_8
  platform_frameworks_av
  platform_frameworks_base
  platform_frameworks_ex
  platform_frameworks_minikin
  platform_frameworks_native
  platform_frameworks_opt_net_wifi
  platform_libcore
  platform_manifest
  platform_packages_apps_Bluetooth
  platform_packages_apps_Camera2
  platform_packages_apps_Contacts
  platform_packages_apps_DeskClock
  platform_packages_apps_ExactCalculator
  platform_packages_apps_Gallery2
  platform_packages_apps_Launcher3
  platform_packages_apps_Music
  platform_packages_apps_Nfc
  platform_packages_apps_PackageInstaller
  platform_packages_apps_QuickSearchBox
  platform_packages_apps_Settings
  platform_packages_inputmethods_LatinIME
  platform_packages_providers_DownloadProvider
  platform_packages_services_Telephony
  platform_prebuilts_clang_host_linux-x86
  platform_system_bt
  platform_system_core
  platform_system_extras
  platform_system_netd
  platform_system_sepolicy
)

declare -A kernels=(
  [google_marlin]=android-msm-marlin-3.18
  [huawei_angler]=android-msm-angler-3.10
  [lge_bullhead]=android-msm-bullhead-3.10
  [linaro_hikey]=hikey-4.9
)

copperhead=(
  android-prepare-vendor
  chromium_patches
  copperhead
  platform_external_chromium
  platform_external_Etar-Calendar
  platform_external_F-Droid
  platform_external_offline-calendar
  platform_external_privacy-friendly-netmonitor
  platform_external_Silence
  platform_packages_apps_Backup
  platform_packages_apps_F-Droid_privileged-extension
  platform_packages_apps_PdfViewer
  platform_packages_apps_Updater
  script
  vendor_linaro
)

for repo in "${aosp_forks[@]}"; do
  echo -e "\n>>> $(tput setaf 3)Handling $repo$(tput sgr0)"

  cd $repo || exit 1

  git checkout $branch || exit 1

  if [[ -n $DELETE_TAG ]]; then
    git tag -d $DELETE_TAG
    git push origin :refs/tags/$DELETE_TAG
    cd .. || exit 1
    continue
  fi

  if [[ -n $build_number ]]; then
    if [[ $repo == platform_manifest ]]; then
      git checkout -B tmp || exit 1
      sed -i s%refs/heads/$branch%refs/tags/$aosp_version.$build_number% default.xml || exit 1
      git commit default.xml -m $aosp_version.$build_number || exit 1
    fi

    git tag -s $aosp_version.$build_number -m $aosp_version.$build_number || exit 1
    git push origin $aosp_version.$build_number || exit 1

    if [[ $repo == platform_manifest ]]; then
      git checkout $branch || exit 1
      git branch -D tmp || exit 1
    fi
  else
    git fetch upstream --tags || exit 1

    git pull --rebase upstream $aosp_tag || exit 1
    git push -f || exit 1
  fi

  cd .. || exit 1
done

for kernel in ${!kernels[@]}; do
  echo -e "\n>>> $(tput setaf 3)Handling kernel_$kernel$(tput sgr0)"

  cd kernel_$kernel || exit 1
  git checkout $branch || exit 1

  if [[ -n $DELETE_TAG ]]; then
    git tag -d $DELETE_TAG
    git push origin :refs/tags/$DELETE_TAG
    cd .. || exit 1
    continue
  fi

  if [[ -n $build_number ]]; then
    git tag -s $aosp_version.$build_number -m $aosp_version.$build_number || exit 1
    git push origin $aosp_version.$build_number || exit 1
  else
    git fetch upstream --tags || exit 1
    suffix=$kernel_suffix
    if [[ $kernel == lge_bullhead ]]; then
      suffix=oreo-r4
    elif [[ $kernel == huawei_angler ]]; then
      suffix=oreo-r5
    elif [[ $kernel == linaro_hikey ]]; then
      suffix=android-8.0.0_r4
    fi
    git pull --rebase upstream ${kernels[$kernel]}-$suffix || exit 1
    git push -f || exit 1
  fi

  cd .. || exit 1
done

for repo in ${copperhead[@]}; do
  echo -e "\n>>> $(tput setaf 3)Handling $repo$(tput sgr0)"

  cd $repo || exit 1
  git checkout $branch || exit 1

  if [[ -n $DELETE_TAG ]]; then
    git tag -d $DELETE_TAG
    git push origin :refs/tags/$DELETE_TAG
    cd .. || exit 1
    continue
  fi

  if [[ -n $build_number ]]; then
    git tag -s $aosp_version.$build_number -m $aosp_version.$build_number || exit 1
    git push origin $aosp_version.$build_number || exit 1
  else
    git push -f || exit 1
  fi

  cd .. || exit 1
done
