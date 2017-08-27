set -e

export TMPDIR=out/tmp
mkdir -p out/tmp

source script/copperhead.sh
choosecombo release aosp_sailfish userdebug

make -j32 target-files-package
make -j32 brillo_update_payload
script/release_ota.sh sailfish
