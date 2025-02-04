#!/bin/sh

set -e
set -u
set -o pipefail

# Set the language
printf "Choose language (1. English, 2. 中文): "
read lang_choice
case $lang_choice in
    1)
        lang="en"
        ;;
    2)
        lang="zh"
        ;;
    *)
        echo "Invalid choice. Defaulting to English."
        lang="en"
        ;;
esac

install_dependencies() {
    echo "$MSG_INSTALLING_DEPENDENCIES"
    apk update && \
    apk add --no-cache \
        build-base \
        wget \
        gmp-dev \
        mpfr-dev \
        mpc1-dev \
        flex \
        bison \
        git \
        curl
}

install_gcc() {
    printf "$MSG_EXECUTE_GCC_INSTALLATION"
    read execute
    if [ "$execute" = "y" ]; then
        echo "$MSG_CLONING_GCC"
        mkdir -p /usr/src/gcc && \
        cd /usr/src/gcc
        rm -rf gcc930-oj
        git clone https://mirror.ghproxy.com/https://github.com/earmer/gcc930-oj.git
        echo "$MSG_CLONE_FINISHED"
        cd gcc930-oj
        ./contrib/download_prerequisites

        echo "$MSG_START_BUILDING"
        mkdir -p build && cd build
        ../configure --enable-languages=c,c++ --disable-multilib
        make -j$(nproc) && \
        make install
        echo "$MSG_BUILD_FINISHED"

        update-alternatives --install /usr/bin/gcc gcc /usr/local/bin/gcc 100 && \
        update-alternatives --install /usr/bin/g++ g++ /usr/local/bin/g++ 100
    fi
}

install_python() {
    printf "$MSG_EXECUTE_PYTHON_INSTALLATION"
    read execute
    if [ "$execute" = "y" ]; then
        echo "$MSG_INSTALLING_PYTHON"
        apk add --no-cache python3 py3-pip
        pip3 install numpy -i https://pypi.tuna.tsinghua.edu.cn/simple
    fi
}

install_openjdk() {
    printf "$MSG_EXECUTE_OPENJDK_INSTALLATION"
    read execute
    if [ "$execute" = "y" ]; then
        echo "$MSG_INSTALLING_OPENJDK"
        apk add --no-cache openjdk17
    fi
}

install_rust() {
    printf "$MSG_EXECUTE_RUST_INSTALLATION"
    read execute
    if [ "$execute" = "y" ]; then
        echo "$MSG_INSTALLING_RUST"
        apk add --no-cache rust cargo
    fi
}

install_go() {
    printf "$MSG_EXECUTE_GO_INSTALLATION"
    read execute
    if [ "$execute" = "y" ]; then
        echo "$MSG_INSTALLING_GO"
        apk add --no-cache go
    fi
}

install_fpc() {
    printf "$MSG_EXECUTE_FPC_INSTALLATION"
    read execute
    if [ "$execute" = "y" ]; then
        echo "$MSG_INSTALLING_FPC"
        apk add --no-cache fpc
    fi
}

install_sandbox() {
    echo "$MSG_INSTALLING_SANDBOX"
    pkill -9 sandbox || true
    if [ -f /usr/bin/sandbox ]; then
        rm /usr/bin/sandbox
    fi
    wget "https://mirror.ghproxy.com/https://github.com/criyle/go-judge/releases/download/v1.8.5/go-judge_1.8.5_linux_amd64" -O /usr/bin/sandbox
    chmod +x /usr/bin/sandbox
    nohup sandbox -http-addr 0.0.0.0:5050 > output.log 2>&1 &
}

main() {
    install_dependencies
    install_gcc
    install_python
    install_openjdk
    install_rust
    install_go
    install_fpc
    install_sandbox
    echo "$MSG_FINISHED"
}

case $lang in
    en)
        export LANG=en_US.UTF-8
        MSG_INSTALLING_DEPENDENCIES="Installing/Renewing basic dependencies..."
        MSG_EXECUTE_GCC_INSTALLATION="Execute GCC 9.3.0 installation? (y/n) "
        MSG_CLONING_GCC="Cloning GCC 9.3.0 for Online Judge"
        MSG_CLONE_FINISHED="Clone Finished"
        MSG_START_BUILDING="Start Making... Take a cup of tea!"
        MSG_BUILD_FINISHED="Build Finished! If the error occurs, please check your system!"
        MSG_EXECUTE_PYTHON_INSTALLATION="Execute Python3 (Numpy) installation? (y/n) "
        MSG_INSTALLING_PYTHON="Installing Python3 (Numpy)"
        MSG_EXECUTE_OPENJDK_INSTALLATION="Execute OpenJDK 17 installation? (y/n) "
        MSG_INSTALLING_OPENJDK="Installing OpenJDK 17"
        MSG_EXECUTE_RUST_INSTALLATION="Execute Rust installation? (y/n) "
        MSG_INSTALLING_RUST="Installing Rust"
        MSG_EXECUTE_GO_INSTALLATION="Execute Go installation? (y/n) "
        MSG_INSTALLING_GO="Installing Go"
        MSG_EXECUTE_FPC_INSTALLATION="Execute FPC installation? (y/n) "
        MSG_INSTALLING_FPC="Installing FPC"
        MSG_INSTALLING_SANDBOX="Installing Sandbox(go-judge)"
        MSG_FINISHED="Finished!"
        ;;
    zh)
        export LANG=zh_CN.UTF-8
        MSG_INSTALLING_DEPENDENCIES="正在安装/更新基本依赖..."
        MSG_EXECUTE_GCC_INSTALLATION="执行 GCC 9.3.0 安装? (y/n) "
        MSG_CLONING_GCC="正在克隆 GCC 9.3.0 用于在线评测"
        MSG_CLONE_FINISHED="克隆完成"
        MSG_START_BUILDING="开始编译... 泡一杯茶吧!"
        MSG_BUILD_FINISHED="编译完成! 如果出错,请检查您的系统!"
        MSG_EXECUTE_PYTHON_INSTALLATION="执行 Python3 (Numpy) 安装? (y/n) "
        MSG_INSTALLING_PYTHON="正在安装 Python3 (Numpy)"
        MSG_EXECUTE_OPENJDK_INSTALLATION="执行 OpenJDK 17 安装? (y/n) "
        MSG_INSTALLING_OPENJDK="正在安装 OpenJDK 17"
        MSG_EXECUTE_RUST_INSTALLATION="执行 Rust 安装? (y/n) "
        MSG_INSTALLING_RUST="正在安装 Rust"
        MSG_EXECUTE_GO_INSTALLATION="执行 Go 安装? (y/n) "
        MSG_INSTALLING_GO="正在安装 Go"
        MSG_EXECUTE_FPC_INSTALLATION="执行 FPC 安装? (y/n) "
        MSG_INSTALLING_FPC="正在安装 FPC"
        MSG_INSTALLING_SANDBOX="正在安装沙箱(go-judge)"
        MSG_FINISHED="安装完成!"
        ;;
esac

main