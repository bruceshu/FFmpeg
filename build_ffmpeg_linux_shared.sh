#!/bin/sh
echo "========================================="
echo "=====build ffmpeg linux shared begin====="
echo "========================================="

ROOT_PATH=`pwd`
RELEASE_PATH=$ROOT_PATH/output/linux/shared

X264_RELEASE_PATH=$RELEASE_PATH
X264_BUILD_PATH=$ROOT_PATH/x264-20170123-90a61ec

X265_RELEASE_PATH=$RELEASE_PATH
X265_BUILD_PATH=$ROOT_PATH/x265-2.2/build/linux

MP3LAME_RELEASE_PATH=$RELEASE_PATH
MP3LAME_BUILD_PATH=$ROOT_PATH/lame-3.99.5

FFMPEG_RELEASE_PATH=$RELEASE_PATH/ffmpeg
FFMPEG_BUILD_PATH=$ROOT_PATH/tmp

#cleaning release files
rm -rf $RELEASE_PATH/*

chmod -R +x *
mkdir -p $RELEASE_PATH

echo "=====build libx264 begin======"
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
cd $X265_BUILD_PATH && rm -rf *

cmake -DCMAKE_INSTALL_PREFIX=$X265_RELEASE_PATH ../../source && cmake ../../source
make && make install

if [ -f "${X265_RELEASE_PATH}/lib/libx265.so.102" ]; then
	cd -
else
	echo "=====build libx265 failed====="
	exit 1
fi

echo "=====build libmp3lame begin====="
cd $MP3LAME_BUILD_PATH
./configure --prefix=$MP3LAME_RELEASE_PATH --enable-shared
make && make install

if [ -f "${MP3LAME_RELEASE_PATH}/lib/libmp3lame.so.0" ]; then
	cd -
else
	echo "=====build libmp3lame failed====="
	exit 1
fi


echo "=====build ffmpeg begin====="
export PKG_CONFIG_PATH=$X265_RELEASE_PATH/lib/pkgconfig:$PKG_CONFIG_PATH
mkdir -p $FFMPEG_RELEASE_PATH

if [ -d $FFMPEG_BUILD_PATH ];then 
	rm -rf $FFMPEG_BUILD_PATH
fi

mkdir -p $FFMPEG_BUILD_PATH
cd $FFMPEG_BUILD_PATH
./../FFmpeg-release-3.1/configure --prefix=$FFMPEG_RELEASE_PATH --enable-shared --disable-ffserver --disable-ffprobe --enable-gpl --enable-libx264 --enable-libx265 --enable-libmp3lame --extra-cflags=-I$RELEASE_PATH/include --extra-ldflags="-L$RELEASE_PATH/lib -lx264 -lpthread -lm -ldl -lmp3lame" --extra-libs=-lstdc++
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


