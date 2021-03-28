# Set VNC base image
FROM digitalcountry/vnc:20.10

# File Author / Maintainer
MAINTAINER ANO "Digital Country"

# Switch to root user to install additional software
USER 0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y git \
                       gcc g++ make swig flex bison \
                       qt5-default \
                       libboost-all-dev \
                       tcl-dev \
                       tcl-tclreadline \
                       liblemon-dev \
                       libeigen3-dev \
                       cimg-dev \
                       python3-dev \
                       zlib1g-dev \
                       lsb-release \
                       freecad \
                       kicad 

# INSTALL CMAKE 3.20
RUN mkdir -p /home/user/tools/cmake && \
    mkdir -p /opt/cmake && \
    cd /home/user/tools/cmake && \
    wget https://github.com/Kitware/CMake/releases/download/v3.20.0/cmake-3.20.0-linux-x86_64.sh && \
    chmod +x ./cmake-3.20.0-linux-x86_64.sh && \
    sh ./cmake-3.20.0-linux-x86_64.sh --prefix=/opt/cmake --skip-license && \
    ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake && \
    cmake --version

# INSTALL SPDLOG
RUN mkdir -p /home/user/tools/spdlog && \
    cd /home/user/tools && \
    git clone https://github.com/gabime/spdlog.git && \
    cd spdlog && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j && \
    make install

# INSTALL LEMON
RUN mkdir -p /home/user/tools/lemon && \
    cd /home/user/tools/lemon && \
    wget http://lemon.cs.elte.hu/pub/sources/lemon-1.3.1.tar.gz && \
    tar --strip-components=1 -zxf lemon-1.3.1.tar.gz && \
    ls -l && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install

# INSTALL OpenROAD
RUN mkdir -p /home/user/tools/OpenROAD && \
    cd /home/user/tools/OpenROAD && \
    git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD.git && \
    ls -l && \
    cd OpenROAD && \
    mkdir build && cd build && ls -l && \
    cmake .. -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_PREFIX_PATH=/home/user/tools/spdlog && \
    make && \
    make install

RUN apt-get autoremove && \
    apt-get clean && \
    rm -fr /home/user/tools

VOLUME /home

## switch back to default user
USER 1000

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["--wait"]
