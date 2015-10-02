#!/bin/bash
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/arch/arm64/boot/Image
DTBTOOL=$KERNEL_DIR/tools/dtbToolCM
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
# Modify the following variable if you want to build
export CROSS_COMPILE="$KERNEL_DIR/../toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
export USE_CCACHE=1
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="ChaOS"
export KBUILD_BUILD_HOST="chaosdroid.com"
export LOCALVERSION="stock-enhancement-r01-beta"



compile_kernel ()
{
rm -rf $KERNEL_DIR/arch/arm64/boot/Image
find . -name '*.ko' -delete;
rm -rf $KERNEL_DIR/arch/arm64/boot/Image.gz
make msm8994-OnePlus2_defconfig
make -j12
if ! [ -a $KERN_IMG ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm64/boot/dts/
strip_modules
}



case $1 in
clean)
make ARCH=arm64 -j8 clean mrproper
;;
*)
compile_kernel
;;
esac
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
echo "Enjoy RazorKernel"
