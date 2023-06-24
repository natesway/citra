#!/bin/bash

#Building Citra
mkdir build
cd build
cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER=/usr/lib/ccache/gcc -DCMAKE_CXX_COMPILER=/usr/lib/ccache/g++ -DENABLE_QT_TRANSLATION=ON -DCITRA_ENABLE_COMPATIBILITY_REPORTING=${ENABLE_COMPATIBILITY_REPORTING:-"OFF"} -DENABLE_COMPATIBILITY_LIST_DOWNLOAD=ON -DENABLE_FFMPEG_AUDIO_DECODER=ON -DUSE_DISCORD_PRESENCE=ON
ninja

ctest -VV -C Release

#Circumvent missing LibFuse in Docker, by extracting the AppImage
export APPIMAGE_EXTRACT_AND_RUN=1

#Building AppDir
DESTDIR="./AppDir" ninja install
mv ./AppDir/usr/local/bin ./AppDir/usr
mv ./AppDir/usr/local/share ./AppDir/usr
rm -rf ./AppDir/usr/local
QMAKE=/usr/lib/qt6/bin/qmake /linuxdeploy-x86_64.AppImage --appdir AppDir --plugin qt --plugin checkrt
sed -i 's/*XFCE*/*X-Cinnamon*|*XFCE*/g' ./AppDir/apprun-hooks/linuxdeploy-plugin-qt-hook.sh
sed -i '/export QT_QPA_PLATFORMTHEME=gtk3/a \ \ \ \ \ \ \ \ export GDK_BACKEND=x11' ./AppDir/apprun-hooks/linuxdeploy-plugin-qt-hook.sh

#Build AppImage
QMAKE=/usr/lib/qt6/bin/qmake /linuxdeploy-x86_64.AppImage --appdir AppDir --output appimage
