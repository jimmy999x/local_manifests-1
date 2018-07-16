#!/bin/bash

export DEVICE=
export ROM=lineage

source build/envsetup.sh

# Jack fixup

./prebuilts/sdk/tools/jack-admin kill-server
rm -rf ~/.jack*
export ANDROID_JACK_VM_ARGS="-Xmx4g -XX:+TieredCompilation -Dfile.encoding=UTF-8"
export SERVER_NB_COMPILE=2
export JACK_SERVER_VM_ARGUMENT=$ANDROID_JACK_VM_ARGS

# You may need to uncomment the following command if Java tells you to use it.
#  ulimit -n unlimited

#./prebuilts/sdk/tools/jack-admin install-server prebuilts/sdk/tools/jack-launcher.jar prebuilts/sdk/tools/jack-server-4.*.ALPHA.jar
#./prebuilts/sdk/tools/jack-admin start-server
#./prebuilts/sdk/tools/jack-admin kill-server
#sed -i "s/jack.server.max-service=4/jack.server.max-service=2/g" ~/.jack-server/config.properties
#./prebuilts/sdk/tools/jack-admin start-server

#ccache
export USE_CCACHE=1
./prebuilts/misc/linux-x86/ccache/ccache -M 100G

upload() {
    FILE=$(ls out/target/product/$DEVICE/*.zip | grep $ROM | grep -v ota | tail -1)
    NAME=$(echo $FILE | sed 's@.*/@@')
#   curl --upload-file $FILE https://transfer.sh/"$NAME"
    gdrive upload $FILE
}

# Clean
if [ "$2" == "clean" ]; then
    echo "Making clean in 10 sec"
    sleep 10
    mka clean
else
    echo "Not making clean"
    sleep 10
fi

# Make
lunch "$ROM"_"$DEVICE"-eng
if [ -z "$1" ]; then
    mka bacon
else
    mka $1
fi

# Upload
if [ -z "$1" ]; then
    upload
elif [ "$1" == "bacon" ]; then
    upload
fi
