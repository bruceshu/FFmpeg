#! /bin/bash

DEST=`pwd`/build/mac && rm -rf $DEST
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
CFLAGS= -O3 -Wall

FFMPEG_FLAGS="
  --disable-debug \
  --disable-doc \
  --disable-x86asm \
  --disable-shared \
  --enable-static"
#=====================================================

#===============COMPILE LINUX===================

cd $SOURCE
make clean
make distclean

PREFIX="$DEST" && mkdir -p $PREFIX
FF_CFG_FLAGS="$FF_CFG_FLAGS $FFMPEG_FLAGS";
FF_CFG_FLAGS="$FF_CFG_FLAGS --prefix=$PREFIX"

./configure $FF_CFG_FLAGS --extra-cflags="$CFLAGS $CFLAGS $EXTRA_CFLAGS" --extra-ldflags="$EXTRA_LDFLAGS" | tee $PREFIX/configuration.txt
cp config.* $PREFIX
[ $PIPESTATUS == 0 ] || exit 1

make -j4 || exit 1
make install || exit 1
