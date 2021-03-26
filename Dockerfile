# Set NPM base image
FROM consol/ubuntu-xfce-vnc:latest

# File Author / Maintainer
MAINTAINER ANO "Digital Country"

# Switch to root user to install additional software
USER 0

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y git wget curl gcc g++ make cmake freecad kicad zip unzip unrar

# INSTALL OpenROAD
RUN git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD.git
RUN cd OpenROAD
RUN mkdir build
RUN cd build
#RUN cmake ..
#RUN make

RUN apt-get clean

VOLUME /home

## switch back to default user
USER 1000