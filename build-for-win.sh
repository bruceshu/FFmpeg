#! /bin/bash

DEST=`pwd`/build/win && rm -rf $DEST
SOURCE=`pwd`/ffmpeg

#=================GET FFMPEG CODE=====================
if [ -d ffmpeg ]; then
  cd ffmpeg
else
  git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg
  cd ffmpeg
fi
#=====================================================

#===============CONFIGURE PARAMETER===================
FF_CFG_FLAGS=
EXTRA_CFLAGS=
EXTRA_LDFLAGS=
CFLAGS=

FFMPEG_FLAGS="--enable-static --disable-shared --disable-x86asm"

#=====================================================

#===============COMPILE Windows===================

cd $SOURCE
make clean
make distclean

PREFIX="$DEST" && mkdir -p $PREFIX
FF_CFG_FLAGS="$FF_CFG_FLAGS $FFMPEG_FLAGS"
FF_CFG_FLAGS="$FF_CFG_FLAGS --prefix=$PREFIX"
FF_CFG_FLAGS="$FF_CFG_FLAGS --arch=x86"
FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-cross-compile"
FF_CFG_FLAGS="$FF_CFG_FLAGS --cross-prefix=x86_64-w64-mingw32-"
FF_CFG_FLAGS="$FF_CFG_FLAGS --target-os=mingw32"

./configure $FF_CFG_FLAGS --extra_cflags="$EXTRA_FLAGS $CFLAGS" --extra_lfags="$EXTRA_LDFLAGS"

cp config.* $PREFIX
[ $PIPESTATUS == 0 ] || exit 1

make -j2 || exit 1
make install || exit 1
