# Taken from the official installation instructions for bigbluebutton 0.81
# http://bigbluebutton.org
#

LIBVPX_VERSION=1.2.0
FFMPEG_VERSION=2.0.1

if [ ! -d "/usr/local/src/libvpx-${LIBVPX_VERSION}" ]; then
  cd /usr/local/src
  sudo git clone http://git.chromium.org/webm/libvpx.git "libvpx-${LIBVPX_VERSION}"
  cd "libvpx-${LIBVPX_VERSION}"
  sudo git checkout "v${LIBVPX_VERSION}"
  sudo ./configure
  sudo make
  sudo checkinstall --pkgname=libvpx --pkgversion="${LIBVPX_VERSION}" --backup=no --deldoc=yes --default
fi

if [ ! -d "/usr/local/src/ffmpeg-${FFMPEG_VERSION}" ]; then
  cd /usr/local/src
  sudo wget "http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2"
  sudo tar -xjf "ffmpeg-${FFMPEG_VERSION}.tar.bz2"
  cd "ffmpeg-${FFMPEG_VERSION}"
  sudo ./configure --enable-version3 --enable-postproc --enable-libvorbis --enable-libvpx
  sudo make
  sudo checkinstall --pkgname=ffmpeg --pkgversion="5:${FFMPEG_VERSION}" --backup=no --deldoc=yes --default
fi