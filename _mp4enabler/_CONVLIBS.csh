#!/bin/csh -f

set verbose

set LIB_DIR = "_mp4enabler/_libs"
mkdir -p $LIB_DIR

cp libavcodec/libavcodec.57.dylib $LIB_DIR
cp libavutil/libavutil.55.dylib $LIB_DIR
cp libavformat/libavformat.57.dylib $LIB_DIR

cd $LIB_DIR

install_name_tool libavcodec.57.dylib -id @loader_path/libavcodec.57.dylib
install_name_tool libavutil.55.dylib -id @loader_path/libavutil.55.dylib
install_name_tool libavformat.57.dylib -id @loader_path/libavformat.57.dylib

foreach w (*.dylib)
    install_name_tool $w -change /usr/local/lib/libavcodec.57.dylib @loader_path/libavcodec.57.dylib
    install_name_tool $w -change /usr/local/lib/libavformat.57.dylib @loader_path/libavformat.57.dylib
    install_name_tool $w -change /usr/local/lib/libavutil.55.dylib @loader_path/libavutil.55.dylib
end
