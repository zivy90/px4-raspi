#
# PX4 base development environment for raspberry pi
#

FROM resin/rpi-raspbian
MAINTAINER Zhiwei Feng 1/26 2018

RUN     apt-get update -y \
# Ubuntu Config
        && echo "We must first remove modemmanager" \
        && apt-get remove modemmanager -y \
# Common dependencies
        && echo "Installing common dependencies" \
        && sudo apt-get install git zip qtcreator cmake build-essential genromfs ninja-build python python-pip unzip wget python-empy python-numpy python-dev nano openjdk-8-jdk \
# Required python packages
        && sudo -H pip install --upgrade pip \
        && sudo pip install numpy toml \
        && sudo -H pip install pandas jinja2 pyserial pyulog 

# Install FastRTPS 1.5.0 and FastCDR-1.0.7
RUN cd ~ \
        && wget http://www.eprosima.com/index.php/component/ars/repository/eprosima-fast-rtps/eprosima-fast-rtps-1-5-0/eprosima_fastrtps-1-5-0-linux-tar-gz -O eprosima_fastrtps-1-5-0-linux.tar \
        && tar -xzf eprosima_fastrtps-1-5-0-linux.tar.gz eProsima_FastRTPS-1.5.0-Linux/ \
        && tar -xzf eprosima_fastrtps-1-5-0-linux.tar.gz requiredcomponents \
        && tar -xzf requiredcomponents/eProsima_FastCDR-1.0.7-Linux.tar.gz \
        && cpucores=$(( $(lscpu | grep Core.*per.*socket | awk -F: '{print $2}') * $(lscpu | grep Socket\(s\) | awk -F: '{print $2}') )) \
        && cd eProsima_FastCDR-1.0.7-Linux; ./configure --libdir=/usr/lib; make -j$cpucores; sudo make install \
        && cd .. \
        && cd eProsima_FastRTPS-1.5.0-Linux; ./configure --libdir=/usr/lib; make -j$cpucores; sudo make install \
        && cd .. \
        && rm -rf requiredcomponents eprosima_fastrtps-1-5-0-linux.tar.gz 

# Clone PX4/Firmware
RUN clone_dir=~/src \
        && mkdir -p $clone_dir \
        && cd $clone_dir \
        && git clone https://github.com/jedichen121/Firmware.git
       
#make corss compilier
RUN cd ~/src/Firmware \
&& make posix_rpi_native \
&& make posix_sitl_default

