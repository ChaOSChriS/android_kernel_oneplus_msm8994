#!/bin/bash
############################################################################################################################
#                  ### OPT Stock enhancement Kernel buildme.sh (C) ChaOSChriS - chaosware19@gmail.com - 2015 ###           #
# 													### www.chaosdroid.com ###                                             #
############################################################################################################################
(
# clear log
#rm "$(pwd)/tmp_build.log"

# colors
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
green='\e[0;32m'

# initializing
clear
echo -e "   $blue## [SCRIPT]$nocol: INITIALIZING: setting variables ... $nocolor"
echo -e ""
sleep 1

# path config
SD="$(pwd)"
CD_DIR="$SD/../_chaosdroid"
TOOLCHAIN="$CD_DIR/toolchains/aarch64-linux-android-4.9/bin"
DTBTOOL="$SD/tools/mkbootimg_tools/dtbTool"
KERN_IMG="$SD/arch/arm64/boot/Image"

# name config
PROJECT="android_kernel_oneplus_msm8994"
CODENAME="plutonium"
DEFCONFIG="msm8994-OnePlus2_defconfig"
OUTDIR="$CD_DIR/out/$CODENAME"
if ! [ -f $OUTDIR ] ; then
mkdir $OUTDIR
fi

# version config
VERSION="r01-beta"
KBU="ChaOS"
KBH="chaosdroid.com"
LV="stock-enhancement-$VERSION"

#buildnumber config
typeset -i BUILDNR=$(cat $CD_DIR/buildnr)
BUILDNR=BUILDNR+1
rm "$CD_DIR/buildnr"
echo $BUILDNR >> "$CD_DIR/buildnr"

# lastrun config
LASTRUN=$(cat $CD_DIR/lastrun)
#rm "$CD_DIR/lastrun"
LASTRUNTIME="$(($LASTRUN / 60)) minute(s) and $(($LASTRUN % 60)) seconds"

# misc config
GCC=$($TOOLCHAIN/aarch64-linux-android-gcc --version)
LOGFILE="$CD_DIR/$PROJECT.$VERSION.$BUILDNR.log"
NRJOBS=$(( $(nproc) * 2 ))

############################################################################################################################
# start
clear
echo -e "$nocolor"
echo -e ""
echo -e ""
echo -e "   $red..######..##.....##....###.....#######...######..########..########...#######..####.########.$nocolor "
echo -e "   $red.##....##.##.....##...##.##...##.....##.##....##.##.....##.##.....##.##.....##..##..##.....##$nocolor "
echo -e "   $red.##.......##.....##..##...##..##.....##.##.......##.....##.##.....##.##.....##..##..##.....##$nocolor "
echo -e "   $red.##.......#########.##.....##.##.....##..######..##.....##.########..##.....##..##..##.....##$nocolor "
echo -e "   $red.##.......##.....##.#########.##.....##.......##.##.....##.##...##...##.....##..##..##.....##$nocolor "
echo -e "   $red.##....##.##.....##.##.....##.##.....##.##....##.##.....##.##....##..##.....##..##..##.....##$nocolor "
echo -e "   $red..######..##.....##.##.....##..#######...######..########..##.....##..#######..####.########.$nocolor "
sleep 1
echo -e "   $blue#############################################################################################$nocolor"

export USE_CCACHE=1
export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE=$TOOLCHAIN/aarch64-linux-android-
export KBUILD_BUILD_USER="$KBU"
export KBUILD_BUILD_HOST="$KBH"
export LOCALVERSION="$LV"

echo -e ""
echo -e ""
echo -e "   $blue## [BUILD]$yellow: INFO: Project: $PROJECT$nocolor"
echo -e "   $blue#############################################################################################$nocolor"
echo -e "   $blue##        $nocol:         device        : $CODENAME$nocolor"
echo -e "   $blue##        $nocol:         config        : $DEFCONFIG$nocolor"
echo -e "   $blue##        $nocol:         version       : $VERSION$nocolor"
echo -e "   $blue##        $nocol:         buildnr       : $BUILDNR$nocolor"
echo -e "   $blue##        $nocol:         last runtime  : $LASTRUNTIME$nocolor"
echo -e "   $blue##        $nocol:         out           : $OUTDIR$nocolor"
echo -e "   $blue##        $nocol:         jobs          : $NRJOBS$nocolor"
echo -e "   $blue#############################################################################################$nocolor"
echo -e "   $blue##        $nocol:         gcc           : "
echo -e ""
echo -e "$GCC"
echo -e ""
sleep 1
echo -e "   $blue#############################################################################################$nocolor"
echo -e "   $blue## [BUILD]$red: WARNING: do you want to continue the building [y/n]?$nocolor"

read -p "" answer
if [[ $answer = n ]] ; then
clear
#cp $TMPLOG $LOGFILE
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START)) 
rm "$CD_DIR/lastrun" 
echo $DIFF >> "$CD_DIR/lastrun" 
echo -e "bye.. $nocolor"
  exit 0
fi

REV=$(git log --pretty=format:'%h' -n 1)
echo -e ""
echo -e "   $blue## [BUILD]$nocol: INFO: Saved current hash as revision: $REV...$nocolor"
echo -e ""
sleep 1

#date of build
DATE=$(date +%Y%m%d)
DATEE=$(date +%H%M%S)
BUILD_START="$(date +"%s")"

echo -e "   $blue## [BUILD]$nocol: INFO: Start of build: $DATE...$nocolor"
echo -e ""
sleep 1
#build the kernel
echo -e "   $blue## [BUILD]$nocol: INFO: Cleaning kernel ...$nocolor"
echo -e ""

sleep 1
make ARCH=arm64 -j$NRJOBS clean mrproper
rm -rf $SD/arch/arm64/boot/Image
find . -name '*.ko' -delete;
rm -rf $SD/arch/arm64/boot/Image.gz
rm `echo -e "   $blue## [BUILD]$nocol: INFO: Cleaning kernel ..." $MODULES_DIR"/*"`

echo -e ""
echo -e "   $blue## [BUILD]$nocol: INFO: make defconfig ...$nocolor"
echo -e ""
sleep 1
make $DEFCONFIG

echo -e "   $blue## [BUILD]$nocol: INFO: Bulding the kernel...$nocolor"
echo -e ""
sleep 1

time make -j$NRJOBS || { return 1; }


if ! [ -f $KERN_IMG ] ; then
echo -e "   $blue## [BUILD]$red: ERROR:$nocol Fix erros! Build failed!$nocolor"
#cp $TMPLOG $LOGFILE
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START)) 
rm "$CD_DIR/lastrun" 
echo $DIFF >> "$CD_DIR/lastrun" 
read -p ""
exit 1
fi


$DTBTOOL -o $SD/arch/arm64/boot/dt.img -s 2048 -p $SD/scripts/dtc/ $SD/arch/arm64/boot/dts/

echo -e "   $blue## [BUILD]$nocol: INFO: creating output folders...$nocolor"
echo -e ""
sleep 1

mkdir -p $OUTDIR/$CODENAME
mkdir -p $OUTDIR/zImage
mkdir -p $OUTDIR/modules

echo -e "   $blue## [BUILD]$nocol: INFO: moving kernel to output...$nocolor"
echo -e ""
sleep 1
find $SD -name '*.ko' -exec cp -v {} $OUTDIR/modules \; 
cp $SD/arch/arm64/boot/Image  $OUTDIR/zImage

# TODO: make flashable zip (anykernel), cleaning out, modules etc ...
#echo -e "   $blue## [BUILD]$nocol: INFO: Cleaning out directory...$nocolor"
#echo -e ""
#sleep 1
#cd $OUTDIR
#find $OUTDIR/* -maxdepth 0 ! -name '*.zip' ! -name '*.txt' ! -name '*.md5' ! -name '*.sha1' ! -name kernel ! -name modules ! -name out ! -name standard ! -name overclocked -exec rm -rf '{}' ';'


echo -e "   $blue## [BUILD]$nocol: INFO: Creating changelog: stock-enhancement_"$CODENAME"_"$REV"_"$VERSION"_"$BUILDNR"_"$DATE".txt ..."
echo -e ""
sleep 1
git log --pretty=format:'%h (%an) : %s' --graph $REV^..HEAD > $OUTDIR/stock-enhancement_"$CODENAME"_"$REV"_"$VERSION"_"$BUILDNR"_"$DATE".txt
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START)) 
rm "$CD_DIR/lastrun" 
echo $DIFF >> "$CD_DIR/lastrun" 
#echo -e "   $blue## [BUILD]$green: INFO: Finished in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds! =) $nocolor"
#cp $TMPLOG $LOGFILE
) 2>&1 | tee "$(pwd)/tmp_build.log"
cp "$(pwd)/tmp_build.log" "$CD_DIR/$PROJECT.$VERSION.$BUILDNR.log"
read -p "   $blue## [BUILD]$green: INFO: Finished in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds! =) $nocolor"
exit 0
