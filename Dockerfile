FROM ubuntu:20.04

RUN apt update

RUN apt install -y vim  \
    tmux \
    build-essential \
    git \
    clang \
    lld \
    wget \
    ninja-build

WORKDIR /opt
RUN wget https://github.com/Kitware/CMake/releases/download/v3.25.2/cmake-3.25.2-linux-x86_64.tar.gz
RUN tar -xzvf cmake-3.25.2-linux-x86_64.tar.gz
WORKDIR /opt/cmake-3.25.2-linux-x86_64
RUN cp -r * /usr

WORKDIR /opt
RUN git clone https://github.com/llvm/llvm-project.git && \
    mkdir llvm-project/build && \
    cd llvm-project/build

WORKDIR /opt/llvm-project/build
RUN cmake -G Ninja ../llvm \
    -DLLVM_ENABLE_PROJECTS=mlir \
    -DLLVM_BUILD_EXAMPLES=ON \
    -DLLVM_TARGETS_TO_BUILD="X86;NVPTX;AMDGPU" \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DLLVM_ENABLE_LLD=ON

RUN cmake --build . -j $(nproc) --target check-mlir

WORKDIR /workspace