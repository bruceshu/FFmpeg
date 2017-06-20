#!/bin/sh
echo "========================================="
echo "=====build ffmpeg win shared begin====="
echo "========================================="
set -e

ROOT_PATH=`pwd`/..
RELEASE_PATH=/home/shuh/openlib

X264_RELEASE_PATH=$RELEASE_PATH/libx264
X264_BUILD_PATH=$ROOT_PATH/ffmpeg/x264-20160920-72d53ab

X265_RELEASE_PATH=$RELEASE_PATH/libx265
X265_BUILD_PATH=$ROOT_PATH/ffmpeg/x265-2.1/build/msys

FFMPEG_RELEASE_PATH=$RELEASE_PATH/ffmpeg
FFMPEG_BUILD_PATH=$ROOT_PATH/ffmpeg

#cleaning release files
rm -rf $RELEASE_PATH/*

echo "=====build libx264 begin======"
mkdir -p $X264_RELEASE_PATH

cd $X264_BUILD_PATH
./configure --prefix=$X264_RELEASE_PATH --enable-shared --host=x86_64-w64-mingw32 --cross-prefix=x86_64-w64-mingw32-
make && make install

if [ -f "${X264_RELEASE_PATH}/bin/libx264-148.dll" ]; then
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

#configure option of cmake 
echo "SET(CMAKE_SYSTEM_NAME Windows)" > toolchain-x86_64-w64-mingw32.cmake
echo "SET(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)" >> toolchain-x86_64-w64-mingw32.cmake
echo "SET(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)" >> toolchain-x86_64-w64-mingw32.cmake
echo "SET(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)" >> toolchain-x86_64-w64-mingw32.cmake
echo "SET(CMAKE_RANLIB x86_64-w64-mingw32-ranlib)" >> toolchain-x86_64-w64-mingw32.cmake
echo "SET(CMAKE_ASM_YASM_COMPILER yasm)" >> toolchain-x86_64-w64-mingw32.cmake

cmake -DCMAKE_INSTALL_PREFIX=$X265_RELEASE_PATH -DCMAKE_TOOLCHAIN_FILE=toolchain-x86_64-w64-mingw32.cmake  ../../source && cmake ../../source
make && make install

if [ -f "${X265_RELEASE_PATH}/bin/libx265.dll" ]; then
	cd -
else
	echo "=====build libx265 failed====="
	exit 1
fi

echo "=====build ffmpeg begin====="
mkdir -p $FFMPEG_RELEASE_PATH
export PKG_CONFIG_PATH=$X264_RELEASE_PATH/lib/pkgconfig:$X265_RELEASE_PATH/lib/pkgconfig

if [ -d $FFMPEG_BUILD_PATH/tmp ];then 
	rm -r $FFMPEG_BUILD_PATH/tmp
fi
mkdir $FFMPEG_BUILD_PATH/tmp

cd $FFMPEG_BUILD_PATH/tmp
../ffmpeg-3.2.1/configure --prefix=$FFMPEG_RELEASE_PATH --enable-shared --enable-gpl --enable-libx264 --enable-libx265 --enable-cross-compile --target-os=mingw32 --arch=x86 --cross-prefix=x86_64-w64-mingw32-
make && make install

if [ -f "${FFMPEG_RELEASE_PATH}/bin/ffmpeg.exe" ]; then
	cd -
else
	echo "=====build ffmpeg failed====="
	exit 1
fi

echo "==========================================="
echo "=====build ffmpeg win shared success====="
echo "==========================================="








