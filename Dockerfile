# Check http://releases.llvm.org/download.html#9.0.0 for the latest available binaries
FROM ubuntu:18.04

ENV USER root
ENV HOME /root

# Set clang as the default copiler
ENV CC=/clang_9.0.0/bin/clang
ENV CXX=/clang_9.0.0/bin/clang++

# Make sure the image is updated, install some prerequisites,
# Download the latest version of Clang (official binary) for Ubuntu
# Extract the archive and add Clang to the PATH
RUN apt-get update && apt-get install -y \
  xz-utils \
  software-properties-common \
  wget \
  build-essential \
  curl \
  cmake \
  libz-dev \
  libtinfo-dev \
  && rm -rf /var/lib/apt/lists/* \
  && curl -SL http://releases.llvm.org/9.0.0/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz \
  | tar -xJC . && \
  mv clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04 clang_9.0.0 && \
  echo 'export PATH=/clang_9.0.0/bin:$PATH' >> ~/.bashrc && \
  echo 'export LD_LIBRARY_PATH=/clang_9.0.0/lib:$LD_LIBRARY_PATH' >> ~/.bashrc

RUN add-apt-repository ppa:kelleyk/emacs && apt-get update \
    && apt-get install -y curl \
                       file \
                       git \
                       emacs26 \
                       doxygen \
                       graphviz \
    && rm -rf /var/lib/apt/lists/*

COPY emacs.d ${HOME}/.emacs.d
RUN emacs --batch -l ${HOME}/.emacs.d/init.el

RUN mkdir -p /tmp/irony_install/ && cd /tmp/irony_install/ && cmake -DCMAKE_INSTALL_PREFIX\=/root/.emacs.d/irony/ \
    /root/.emacs.d/elpa/irony-20200130.849/server && \
        cmake --build . --use-stderr --config Release --target install && \
        rm -rf /tmp/*

# Start from a Bash prompt
CMD [ "/bin/bash" ]
