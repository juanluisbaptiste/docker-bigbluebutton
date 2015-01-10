# Taken from the official installation instructions for bigbluebutton 0.81
# http://bigbluebutton.org
#

LIBVPX_VERSION=1.2.0
FFMPEG_VERSION=2.0.1
BUILD_LIBVPX=0
PKG_DIR="/tmp/build"

use()
{
cat << EOF
Use: $0 [-d] [-r] [-l] [-h]

Script to build ffmpeg library.

OPTIONS:
-h    Shows the program's help
-f    ffmpeg version to build
-b    Build libvpx
-l    libvpx version to build
-o    Debian package output directory

EOF
}

while getopts "hf:bl:" OPTION
                   do
    case $OPTION in
        h)
            use
            exit 1
            ;;
        b)
            BUILD_LIBVPX=1
            ;;
        f)
            FFMPEG_VERSION=$OPTARG
            ;;
        l)
            LIBVPX_VERSION=$OPTARG
            ;;            
        l)
            PKG_DIR=$OPTARG
            ;;                        
        ?)
            use
            exit
            ;;
    esac
done


if [ $BUILD_LIBVPX -eq 1 ]; then
	if [ ! -d "/usr/local/src/libvpx-${LIBVPX_VERSION}" ]; then
		echo "Building libvpx version: $LIBVPX_VERSION\n"
		cd /usr/local/src
		sudo git clone http://git.chromium.org/webm/libvpx.git "libvpx-${LIBVPX_VERSION}"
		cd "libvpx-${LIBVPX_VERSION}"
		sudo git checkout "v${LIBVPX_VERSION}"
		sudo ./configure
		sudo make
		sudo checkinstall --pkgname=libvpx --pkgversion="${LIBVPX_VERSION}" --backup=no --deldoc=yes --default --pakdir=$PKG_DIR
	fi
fi

if [ ! -d "/usr/local/src/ffmpeg-${FFMPEG_VERSION}" ]; then
  echo "Building ffmpeg version: $FFMPEG_VERSION\n"
  cd /usr/local/src
  sudo wget "http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2"
  sudo tar -xjf "ffmpeg-${FFMPEG_VERSION}.tar.bz2"
  cd "ffmpeg-${FFMPEG_VERSION}"
  sudo ./configure --enable-version3 --enable-postproc --enable-libvorbis --enable-libvpx
  sudo make
  sudo checkinstall --pkgname=ffmpeg --pkgversion="5:${FFMPEG_VERSION}" --backup=no --deldoc=yes --default --pakdir=$PKG_DIR
fi