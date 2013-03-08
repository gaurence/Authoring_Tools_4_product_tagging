# ------------------------------------------------------------------------------
#
# OpenCV2 installation script
# Usage : Type sh install-opencv2.sh -h for usage or help
# Author : Rajeev Kumar Jeevagan
# Last Modified : January 28, 2013
#
# --------------------- FreeBSD License ----------------------------------------
# Copyright (c) <2013>, <Rajeev Kumar Jeevagan>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met: 
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer. 
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution. 
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies, 
# either expressed or implied, of the FreeBSD Project.
# -------------------------------------------------------------------------------
#!/bin/bash
if [ `id | cut -d= -f2 | cut -d\( -f1` = 0 ]
then
  echo "Starting OpenCV-2.4.3 installation ..."
else
  
  if [ $1 =  ]
  then  
    echo "You dont have root permission. Try with sudo"
    exit 0
  elif [ `echo $1 | cut -d\- -f2` = "h" ]
  then
    echo
    echo "------------------- OpenCV2 installation Usage ----------------------"
    echo
    echo "For installation always use it with administrative permission"
    echo 
    echo "Standard Usage:"
    echo "sudo sh install-opencv2.sh" 
    echo "This downloads and installs OpenCV2.4.3 and all dependencies by creating a ProgramFiles directory in your home folder and sets up .bashrc"
    echo
    echo "Options"
    echo
    echo "-h        Help or Usage instructions"
    echo "-path     Installation path"
    echo "-tbb      Compile OpenCV2 with tbb support"
    echo "-qt       Compile OpenCV2 with qt support (currently not configured)"
    echo "-eigen    Compile OpenCV2 with eigen support"
    echo
    echo "The script will take care of downloading these libraries for you"
    echo
    echo "---------------------------------------------------------------------" 
    echo
    exit 0
  else
    echo "You dont have root permission. Try with sudo"
    exit 0
  fi
fi

# Determine 64 bit or 32 bit system
echo; echo "Determining system configuration ..."
if grep -iwq lm /proc/cpuinfo
then
  flag_64bit=true
else
  flag_64bit=false
fi
echo "64 bit system - Preparing to install 64-bit version OpenCV"
  
# Determining installation path
cnt=0
install_path="~/ProgramFiles/"
for i in $*
do
  cnt=`expr $cnt + 1`
  if [ `echo $i | cut -d\- -f2` = "path" ]
  then
    cnt=`expr $cnt + 1`
    eval install_path=\$${cnt}
  fi
done
echo $install_path
mkdir $install_path
cd $install_path
echo; echo "Installation Directory - $install_path"

# Determining additional configuration parameters
for i in $*
do
  if [ `echo $i | cut -d\- -f2` = "tbb" ] # tbb Installation
  then
    apt-get -y install libtbb2 libtbb-dev
    opencv_compiler_cmd=$opencv_compiler_cmd + "-D WITH_TBB=ON "
    echo; echo "TBB support included"
  elif [ `echo $i | cut -d\- -f2` = "eigen" ] # Eigen Installation
  then
    wget http://bitbucket.org/eigen/eigen/get/3.1.2.tar.bz2
    tar xvf 3.1.2.tar.bz2
    cd eig*
    mkdir build
    cd build
    cmake ..
    make install
    echo; echo "Eigen support included"
    cd $install_path
  fi
done

echo; echo "Removing previous versions of ffmpeg and x264"; echo
apt-get remove ffmpeg x264 libx264-dev

echo; echo "Updating Packages"; echo
apt-get update

# Installing Dependencies for x264 and ffmpeg
echo; echo "Installing dependencies for x264"; echo
apt-get -y install build-essential checkinstall git cmake libjack-jackd2-dev libmp3lame-dev libopencore-amrnb-dev libopencore-amrwb-dev libsdl1.2-dev libtheora-dev libva-dev libvdpau-dev libvorbis-dev libx11-dev libxfixes-dev libxvidcore-dev texi2html yasm zlib1g-dev

# Install gstreamer
echo; echo "Installing gstreamer"; echo
apt-get -y install libgstreamer0.10-0 libgstreamer0.10-dev gstreamer0.10-tools gstreamer0.10-plugins-base libgstreamer-plugins-base0.10-dev gstreamer0.10-plugins-good gstreamer0.10-plugins-ugly gstreamer0.10-plugins-bad gstreamer0.10-ffmpeg

# Install gtk
echo; echo "Installing gtk"; echo
apt-get -y install libgtk2.0-0 libgtk2.0-dev1

# Install libjpeg
echo; echo "Installing libjpeg"; echo
apt-get -y install libjpeg8 libjpeg8-dev


# Download and Install x264
echo; echo "Downloading and Installing x264"; echo
wget ftp://ftp.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-20130130-2245-stable.tar.bz2
tar xvf x264-snapshot-20130130-2245-stable.tar.bz2
cd x264-snapshot-20130130-2245-stable

if flag_64bit
then
  ./configure --enable-shared --enable-pic
else
  ./configure --enable-static
fi
make
make install

# Download and Install ffmpeg
echo; echo "Downloading and Installing ffmpeg"; echo
cd $install_path
wget http://ffmpeg.org/releases/ffmpeg-1.1.1.tar.bz2
tar xvf ffmpeg-1.1.1.tar.bz2
cd ffmpeg-1.1.1

if flag_64bit
then
  ./configure --enable-gpl --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libxvid --enable-nonfree --enable-postproc --enable-version3 --enable-x11grab --enable-shared --enable-pic
else
  ./configure --enable-gpl --enable-libfaac --enable-libmp3lame --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libxvid --enable-nonfree --enable-postproc --enable-version3 --enable-x11grab
fi
make
make install

# Download and Install v4l
echo; echo "Downloading and Installing v4l"; echo
cd $install_path
wget http://www.linuxtv.org/downloads/v4l-utils/v4l-utils-0.9.3.tar.bz2
tar xvf v4l-utils-0.9.3.tar.bz2
cd v4l-utils-0.9.3

if flag_64bit
then
  ./configure --enable-shared --enable-pic # Potential Error
else
  ./configure
fi
make
make install

# Download and Install OpenCV-2.4.3
echo; echo "Downloading and Installing OpenCV2"; echo
cd $install_path
wget http://downloads.sourceforge.net/project/opencvlibrary/opencv-unix/2.4.3/OpenCV-2.4.3.tar.bz2
tar xvf OpenCV-2.4.3.tar.bz2
cd OpenCV-2.4.3
mkdir build
cd build
cmake $opencv_compiler_command -D CMAKE_BUILD_TYPE=RELEASE .. 
make
make install

# OpenCV system configuration
echo; echo "Configuring OpenCV"
echo "/usr/local/lib" >> /etc/ld.so.conf.d/opencv.conf
ldconfig /etc/ld.so.conf

echo >> ~/.bashrc
echo "# OpenCV Configuration" >> ~/.bashrc
echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig" >> ~/.bashrc
echo "export PKG_CONFIG_PATH" >> ~/.bashrc

echo; echo "Installation Completed Successfully!!"