FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
        git \
        wget \
        gnupg2 \
        software-properties-common \
    &&\
    rm -rf /var/lib/apt/lists/*

RUN wget -nv -O - http://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - &&\
    apt-add-repository -y "deb http://apt.llvm.org/`lsb_release -cs`/ llvm-toolchain-`lsb_release -cs` main" &&\
    apt-add-repository -y "deb http://apt.llvm.org/`lsb_release -cs`/ llvm-toolchain-`lsb_release -cs`-12 main" &&\
    apt-add-repository -y "deb http://apt.llvm.org/`lsb_release -cs`/ llvm-toolchain-`lsb_release -cs`-13 main" &&\
    apt-get install -y --no-install-recommends \
        clang-format-6.0 \
        clang-format-7 \
        clang-format-8 \
        clang-format-9 \
        clang-format-10 \
        clang-format-11 \
        clang-format-12 \
        clang-format-13 \
    &&\
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

COPY check_clang_format_compliance.sh /usr/bin/check_clang_format_compliance
RUN chmod 755 /usr/bin/check_clang_format_compliance

ENTRYPOINT ["/entrypoint.sh"]
