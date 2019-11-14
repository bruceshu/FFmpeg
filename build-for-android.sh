#!/bin/bash
DEST=`pwd`/build/android && rm -rf $DEST
SOURCE=`pwd`/ffmpeg

#=================GET FFMPEG CODE=====================
if [ -d ffmpeg ]; then
  cd ffmpeg
else
  git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg
  cd ffmpeg
fi
#=====================================================

#====================TOOLCHAIN========================
TOOLCHAIN_32=/tmp/dtp_32
$ANDROID_NDK/build/tools/make_standalone_toolchain.py --api=19 --arch=arm --force --install-dir=$TOOLCHAIN_32

TOOLCHAIN_64=/tmp/dtp_64
$ANDROID_NDK/build/tools/make_standalone_toolchain.py --api=24 --arch=arm64 --force --install-dir=$TOOLCHAIN_64

export PATH=$TOOLCHAIN_32/bin:$PATH
export PATH=$TOOLCHAIN_64/bin:$PATH
#=====================================================


#===============CONFIGURE PARAMETER===================
FF_CFG_FLAGS=
EXTRA_CFLAGS=
EXTRA_LDFLAGS=

CFLAGS="-O3 -Wall -pipe \
    -std=c99 \
    -ffast-math \
    -fno-strict-aliasing -Werror=strict-aliasing \
    -Wno-psabi -Wa,--noexecstack \
    -DANDROID -DNDEBUG"

FFMPEG_FLAGS="
  --disable-debug \
  --disable-symver \
  --disable-doc \
  --disable-ffplay \
  --disable-ffmpeg \
  --disable-ffprobe \
  --disable-avdevice \
  --disable-encoders \
  --disable-muxers \
  --disable-devices \
  --disable-indevs \
  --disable-outdevs \
  --disable-demuxers \
  --disable-decoders \
  --disable-asm \
  --disable-linux-perf \
  
  --enable-shared \
  --enable-static"
#=====================================================

#===============COMPILE ARMV7 ARMV8===================
for version in armv7 armv8; do

  cd $SOURCE
  make clean
  make distclean

  case $version in
    armv7)
      FF_CFG_FLAGS="--arch=arm --cpu=cortex-a8"
      FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-neon"
      FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-thumb"
      FF_CROSS_PREFIX=arm-linux-androideabi
      
      EXTRA_CFLAGS="-march=armv7-a -mcpu=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=softfp -mthumb"
      EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
      ;;
    armv8)
      FF_CFG_FLAGS="--arch=aarch64"
      FF_CROSS_PREFIX=aarch64-linux-android
      
      EXTRA_CFLAGS=""
      EXTRA_LDFLAGS=""
      ;;
    *)
      EXTRA_CFLAGS=""
      EXTRA_LDFLAGS=""
      ;;
  esac

  PREFIX="$DEST/$version" && mkdir -p $PREFIX
  FF_CFG_FLAGS="$FF_CFG_FLAGS $FFMPEG_FLAGS";
  FF_CFG_FLAGS="$FF_CFG_FLAGS --prefix=$PREFIX"
  FF_CFG_FLAGS="$FF_CFG_FLAGS --cross-prefix=${FF_CROSS_PREFIX}-"
  FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-cross-compile"
  FF_CFG_FLAGS="$FF_CFG_FLAGS --target-os=android"


  ./configure $FF_CFG_FLAGS --extra-cflags="$CFLAGS $EXTRA_CFLAGS" --extra-ldflags="$EXTRA_LDFLAGS" | tee $PREFIX/configuration.txt
  cp config.* $PREFIX
  [ $PIPESTATUS == 0 ] || exit 1

  make -j4 || exit 1
  make install || exit 1
done
