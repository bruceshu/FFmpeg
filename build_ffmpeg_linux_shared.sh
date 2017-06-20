#!/bin/sh
echo "========================================="
echo "=====build ffmpeg linux shared begin====="
echo "========================================="

ROOT_PATH=`pwd`/..
RELEASE_PATH=/home/shuh/openlib

X264_RELEASE_PATH=$RELEASE_PATH/libx264
X264_BUILD_PATH=$ROOT_PATH/ffmpeg/x264-20160920-72d53ab

X265_RELEASE_PATH=$RELEASE_PATH/libx265
X265_BUILD_PATH=$ROOT_PATH/ffmpeg/x265-2.1/build/linux

FFMPEG_RELEASE_PATH=$RELEASE_PATH/ffmpeg
FFMPEG_BUILD_PATH=$ROOT_PATH/ffmpeg

#cleaning release files
rm -rf $RELEASE_PATH/*

echo "=====build libx264 begin======"
mkdir -p $X264_RELEASE_PATH

cd $X264_BUILD_PATH
./configure --prefix=$X264_RELEASE_PATH --enable-shared
make && make install

if [ -f "${X264_RELEASE_PATH}/lib/libx264.so.148" ]; then
	cd -
else
	echo "=====build libx264 failed====="
	exit 1
fi

echo "=====build libx265 begin====="
mkdir -p $X265_RELEASE_PATH

cd $X265_BUILD_PATH
#cleaning having built files  
rm -rf *

cmake -DCMAKE_INSTALL_PREFIX=$X265_RELEASE_PATH ../../source && cmake ../../source
make && make install

if [ -f "${X265_RELEASE_PATH}/lib/libx265.so.95" ]; then
	cd -
else
	echo "=====build libx265 failed====="
	exit 1
fi

echo "=====build ffmpeg begin====="
export PKG_CONFIG_PATH=$X264_RELEASE_PATH/lib/pkgconfig:$X265_RELEASE_PATH/lib/pkgconfig

if [ -d $FFMPEG_BUILD_PATH/tmp ];then 
	rm -r $FFMPEG_BUILD_PATH/tmp
fi
mkdir $FFMPEG_BUILD_PATH/tmp

cd $FFMPEG_BUILD_PATH/tmp
../ffmpeg-3.2.1/configure --prefix=$FFMPEG_RELEASE_PATH --enable-shared --enable-gpl --enable-libx264 --enable-libx265
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


