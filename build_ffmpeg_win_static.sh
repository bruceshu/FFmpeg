#!/bin/sh
echo "========================================="
echo "=====build ffmpeg win static begin====="
echo "========================================="
set -e

ROOT_PATH=`pwd`
RELEASE_PATH=$ROOT_PATH/output/win/static

X264_RELEASE_PATH=$RELEASE_PATH
X264_BUILD_PATH=$ROOT_PATH/x264-20170123-90a61ec

X265_RELEASE_PATH=$RELEASE_PATH
X265_BUILD_PATH=$ROOT_PATH/x265-2.2/build/msys

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
./configure --prefix=$X264_RELEASE_PATH --enable-static --host=x86_64-w64-mingw32 --cross-prefix=x86_64-w64-mingw32-
make && make install

if [ -f "${X264_RELEASE_PATH}/lib/libx264.a" ]; then
	cd -
else
	echo "=====build libx264 failed====="
	exit 1
fi

echo "=====build libx265 begin====="
cd $X265_BUILD_PATH && rm -rf *

#the configure of compiling x265 which running on windows 
#configure option of cmake 
echo "SET(CMAKE_SYSTEM_NAME Windows)" > toolchain-x86_64-w64-mingw32.cmake
echo "SET(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)" >> toolchain-x86_64-w64-mingw32.cmake
echo "SET(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)" >> toolchain-x86_64-w64-mingw32.cmake
echo "SET(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)" >> toolchain-x86_64-w64-mingw32.cmake
echo "SET(CMAKE_RANLIB x86_64-w64-mingw32-ranlib)" >> toolchain-x86_64-w64-mingw32.cmake
echo "SET(CMAKE_ASM_YASM_COMPILER yasm)" >> toolchain-x86_64-w64-mingw32.cmake
cmake -DCMAKE_INSTALL_PREFIX=$X265_RELEASE_PATH -DENABLE-SHARED=no -DCMAKE_TOOLCHAIN_FILE=toolchain-x86_64-w64-mingw32.cmake  ../../source && cmake ../../source
make && make install

if [ -f "${X265_RELEASE_PATH}/lib/libx265.a" ]; then
	rm -rf ${X265_RELEASE_PATH}/lib/libx265.dll.a
	cd -
else
	echo "=====build libx265 failed====="
	exit 1
fi


echo "=====build libmp3lame begin====="
#cd $MP3LAME_BUILD_PATH
#./configure --prefix=$MP3LAME_RELEASE_PATH --enable-static --disable-shared
#make && make install

if [ -f "${MP3LAME_RELEASE_PATH}/lib/libmp3lame.a" ]; then
	rm -f ${MP3LAME_RELEASE_PATH}/lib/libmp3lame.so*
	cd -
else
	echo "=====build libmp3lame failed====="
	#exit 1
fi


echo "=====build ffmpeg begin====="
mkdir -p $FFMPEG_RELEASE_PATH
export PKG_CONFIG_PATH=$X265_RELEASE_PATH/lib/pkgconfig:$PKG_CONFIG_PATH
if [ -d $FFMPEG_BUILD_PATH ];then 
	rm -r $FFMPEG_BUILD_PATH
fi
mkdir $FFMPEG_BUILD_PATH

cd $FFMPEG_BUILD_PATH
./../FFmpeg-release-3.1/configure --prefix=$FFMPEG_RELEASE_PATH --enable-static --disable-shared --enable-gpl --enable-libx264 --enable-libx265 --extra-cflags=-I$RELEASE_PATH/include --extra-ldflags="-L$RELEASE_PATH/lib -lx264 -lpthread -lm -lstdc++ -lmoldname -lmingwex -lmsvcrt -ladvapi32 -lshell32 -luser32 -lkernel32 -lmoldname -lmingwex -lmsvcrt" --enable-cross-compile --target-os=mingw32 --arch=x86 --cross-prefix=x86_64-w64-mingw32-
make && make install

if [ -f "${FFMPEG_RELEASE_PATH}/bin/ffmpeg.exe" ]; then
	cd -
else
	echo "=====build ffmpeg failed====="
	exit 1
fi

echo "==========================================="
echo "=====build ffmpeg win static success====="
echo "==========================================="








