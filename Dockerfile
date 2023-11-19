# Use an official Ubuntu runtime as a parent image
FROM ubuntu:latest

# Set the working directory to /app
WORKDIR /app

# Update the package list and install necessary tools
RUN apt-get update && \
    apt-get install -y \
    net-tools \
    cmake \
    build-essential \
    wget \
    git \
    unzip \
    openjdk-8-jdk \
    doxygen \
    libgtest-dev

# Download and install Boost 1.58
RUN wget https://sourceforge.net/projects/boost/files/boost/1.65.1/boost_1_65_1.tar.gz && \
    tar -xf boost_1_65_1.tar.gz && \
    cd boost_1_65_1 && \
    ./bootstrap.sh --prefix=/usr/ && \
    ./b2 && \
    ./b2 install && \
    cd .. && \
    rm -rf boost_1_65_1.tar.gz boost_1_65_1

# Clone and build capicxx-core-runtime
RUN git clone https://github.com/GENIVI/capicxx-core-runtime.git && \
    cd capicxx-core-runtime && \
    git checkout tags/3.1.12.6 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j && \
    cd ../.. && \
    mkdir COMMONAPI && \
    cp -d capicxx-core-runtime/build/lib* COMMONAPI

# Clone and build vSomeIP
RUN git clone http://github.com/GENIVI/vSomeIP.git && \
    cd vSomeIP && \
    git checkout tags/2.14.16 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    sh -c "sed  -i 's/#include <cstdint>/#include <cstdint>\n#include <string>/' ../interface/vsomeip/primitive_types.hpp" && \
    make -j && \
    cd ../.. && \
    cp -d vSomeIP/build/lib* COMMONAPI

# Clone and build capicxx-someip-runtime
RUN git clone https://github.com/GENIVI/capicxx-someip-runtime.git && \
    cd capicxx-someip-runtime && \
    git checkout tags/3.1.12.9 && \
    mkdir build && \
    cd build && \
    cmake -DUSE_INSTALLED_COMMONAPI=OFF .. && \
    make -j && \
    cd ../.. && \
    cp -d capicxx-someip-runtime/build/lib* COMMONAPI

# Download and extract the generators
RUN wget https://github.com/COVESA/capicxx-core-tools/releases/download/3.1.12.4/commonapi-generator.zip && \
    wget https://github.com/COVESA/capicxx-someip-tools/releases/download/3.1.12/commonapi_someip_generator.zip && \
    unzip commonapi-generator.zip -d commonapi-generator && \
    unzip commonapi_someip_generator.zip -d commonapi_someip_generator && \
    chmod +x commonapi-generator/commonapi-generator-linux-x86_64 && \
    chmod +x commonapi_someip_generator/commonapi-someip-generator-linux-x86_64 && \
    rm -f commonapi-generator.zip commonapi_someip_generator.zip

# Update LD_LIBRARY_PATH
RUN echo "export LD_LIBRARY_PATH=${PWD}/COMMONAPI" >> /root/.bashrc

# Clone the example Hello World project
RUN git clone https://github.com/moatasemelsayed/vsomeip_helloworld.git

# Set the entry point to /bin/bash
CMD ["/bin/bash"]

