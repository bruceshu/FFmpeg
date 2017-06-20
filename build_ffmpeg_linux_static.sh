#!/bin/sh
echo "========================================="
echo "=====build ffmpeg linux shared begin====="
echo "========================================="

ROOT_PATH=`pwd`
RELEASE_PATH=$ROOT_PATH/output

X264_RELEASE_PATH=$RELEASE_PATH/libx264
X264_BUILD_PATH=$ROOT_PATH/x264-20170123-90a61ec

X265_RELEASE_PATH=$RELEASE_PATH/libx265
X265_BUILD_PATH=$ROOT_PATH/x265-2.2/build/linux

FFMPEG_RELEASE_PATH=$RELEASE_PATH/ffmpeg
FFMPEG_BUILD_PATH=$ROOT_PATH/FFmpeg-release-3.1

chmod -R +x *

echo "=====build libx264 begin======"
mkdir -p $X264_RELEASE_PATH

cd $X264_BUILD_PATH
./configure --prefix=$X264_RELEASE_PATH --enable-static
make && make install

if [ -f "${X264_RELEASE_PATH}/lib/libx264.a" ]; then
	cd -
else
	echo "=====build libx264 failed====="
	exit 1
fi

echo "=====build libx265 begin====="
mkdir -p $X265_RELEASE_PATH

cd $X265_BUILD_PATH
cmake -DCMAKE_INSTALL_PREFIX=$X265_RELEASE_PATH -DENABLE_SHARED=no ../../source && cmake ../../source
make && make install

if [ -f "${X265_RELEASE_PATH}/lib/libx265.a" ]; then
	cd -
else
	echo "=====build libx265 failed====="
	exit 1
fi

echo "=====build ffmpeg begin====="
export PKG_CONFIG_PATH=$X264_RELEASE_PATH/lib/pkgconfig:$X265_RELEASE_PATH/lib/pkgconfig
mkdir -p $FFMPEG_RELEASE_PATH

cd $FFMPEG_BUILD_PATH
./configure --prefix=$FFMPEG_RELEASE_PATH --enable-static --enable-gpl --enable-libx264 --enable-libx265 --extra-libs='-lstdc++'
make && make install

if [ -f "${FFMPEG_RELEASE_PATH}/bin/ffmpeg" ]; then
	cd -
else
	echo "=====build ffmpeg failed====="
	exit 1
fi

echo "==========================================="
echo "=====build ffmpeg linux shared success====="
echo "==========================================="




