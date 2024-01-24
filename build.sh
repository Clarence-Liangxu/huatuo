#!/usr/bin/env bash

program='build-gcc.sh'
version='(unvrsioned)'

declare -r PROJ_ROOT="$(cd `dirname $0`; pwd)"

declare -r DEP_DIR="${PROJ_ROOT}/open_source"
declare -r GCC_INSTALL="${DEP_DIR}/gcc-install"
declare -r DEP_INSTALL="${GCC_INSTALL}"
declare -r logfile="${PROJ_ROOT}/build.log"
declare JOBS
declare Darwin_flags

GCC_PKG="gcc-12-branch-gcc-12.3-darwin-r0"
GCC_SUFFIX=".tar.gz"
GMP_PKG="gmp-6.2.1"
GMP_SUFFIX=".tar.bz2"
MPFR_PKG="mpfr-4.1.0"
MPFR_SUFFIX=".tar.bz2"
MPC_PKG="mpc-1.2.1"
MPC_SUFFIX=".tar.gz"
ISL_PKG="isl-0.24"
ISL_SUFFIX=".tar.bz2"

base_url='https://mirrors.aliyun.com/gnu'
gmp_url="$base_url/gmp/$GMP_PKG$GMP_SUFFIX"
mpc_url="$base_url/mpc/$MPC_PKG$MPC_SUFFIX"
mpfr_url="$base_url/mpfr/$MPFR_PKG$MPFR_SUFFIX"
gcc_url="$base_url/gcc/$GCC_PKG/$GCC_PKG$GCC_SUFFIX"

OS="`uname`"
echo "[Info] running on $OS."

case $OS in
    'Darwin')
	JOBS="$(sysctl -n hw.ncpu)"
	Darwin_flags="--with-sysroot=/Library/Developer/CommandLineTools/SDKs/MacOSX13.sdk"
	;;
    'Linux')
	JOBS="$(grep --count ^processor /proc/cpuinfo)"
	;;
    *)
	echo "[Error] not support on this platform. (Linux or Darwin)"
	exit 1
	;;
esac

echo "[Info] JOBS ${JOBS}"

function help_msg()
{
    echo "hellp"
}

function download_dependency()
{
    echo "download_dependency"
    cd $DEP_DIR
    if [ ! -f $GMP_PKG$GMP_SUFFIX ]; then
	wget $gmp_url || { echo "download gmp failed"; return 1; }
    fi

    if [ ! -f $MPC_PKG$MPC_SUFFIX ]; then
	wget $mpc_url || { echo "download mpc failed"; return 1; }
    fi

    if [ ! -f $MPFR_PKG$MPFR_SUFFIX ]; then
	wget $mpfr_url || { echo "download mpfr failed"; return 1; }
    fi

    if [ ! -f $GCC_PKG$GCC_SUFFIX ]; then
	wget $gcc_url || { echo "download gcc failed"; return 1; }
    fi
    

    return 0
}

function build_gmp()
{
    echo "build gmp"
    cd ${DEP_DIR}
    rm -rf ${GMP_PKG}
    tar -xf ${GMP_PKG}${GMP_SUFFIX} || { echo "tar gmp failed"; return 1; }
    cd ${GMP_PKG}
    mkdir build
    cd build
    ../configure --prefix=${GCC_INSTALL} || return 1
    make -j${JOBS} || return 1
    make install || return 1
    return 0
}

function build_isl()
{
    echo "build isl"
    cd ${DEP_DIR}
    rm -rf ${ISL_PKG}
    tar -xf ${ISL_PKG}${ISL_SUFFIX} || { echo "tar isl failed"; return 1; }
    cd ${ISL_PKG}
    mkdir build
    cd build
    ../configure --prefix=${DEP_INSTALL} --with-gmp=${DEP_INSTALL} || return 1
    make -j${JOBS} || return 1
    make install || return 1
    return 0
}

function build_mpc()
{
    echo "build mpc"
    cd ${DEP_DIR}
    rm -rf ${MPC_PKG}
    tar -xf ${MPC_PKG}${MPC_SUFFIX} || { echo "tar ${MPC_PKG}${MPC_SUFFIX} failed"; return 1; }
    cd ${MPC_PKG}
    mkdir build
    cd build
    ../configure --prefix=${DEP_INSTALL} \
	      --with-gmp=${DEP_INSTALL} \
	      --with-mpfr=${DEP_INSTALL} || return 1
    make -j${JOBS} || return 1
    make install || return 1
    return 0
}

function build_mpfr()
{
    echo "build mpfr"
    cd ${DEP_DIR}
    rm -rf ${MPFR_PKG}
    tar -xf ${MPFR_PKG}${MPFR_SUFFIX} || { echo "tar mpfr failed"; return 1; }
    cd ${MPFR_PKG}
    mkdir build
    cd build
    ../configure --prefix=${DEP_INSTALL} \
	       --with-gmp=${DEP_INSTALL} || return 1
    make -j${JOBS} || return 1
    make install || return 1
    return 0
}

function build_gcc_prerequist()
{
    echo "build prerequist"
    download_dependency || { echo "download dependency failed"; return 1; }
    build_gmp || { echo "build gmp failed"; return 1; }
    build_mpfr || { echo "build mpfr failed"; return 1; }
    build_mpc || { echo "build mpc failed"; return 1; }
}

function build_gcc()
{
    echo "build gcc"
    cd ${DEP_DIR}
    rm -rf ${GCC_PKG}
    tar -xf ${GCC_PKG}${GCC_SUFFIX} || { echo "tar gcc failed"; return 1; }
    cd ${GCC_PKG}
    mkdir build
    cd build
    ../configure --prefix="${GCC_INSTALL}" \
		 --libdir="${GCC_INSTALL}/lib/gcc/12" \
		 --disable-nls --enable-checking=release \
		 --with-gcc-major-version-only \
		 --enable-languages=c,c++,objc,obj-c++,fortran \
		 --program-suffix=-12 \
		 --with-gmp=/opt/homebrew/opt/gmp \
		 --with-mpfr=/opt/homebrew/opt/mpfr \
		 --with-mpc=/opt/homebrew/opt/libmpc \
		 --with-isl=/opt/homebrew/opt/isl \
		 --with-zstd=/opt/homebrew/opt/zstd  \
		 --with-system-zlib \
		 --build=aarch64-apple-darwin23 \
		 --with-sysroot=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk \
		 --with-ld=/Library/Developer/CommandLineTools/usr/bin/ld-classic \
		 --enable-plugin \
		 --enable-lto || { echo "gcc configure failed"; return 1; }
    
    make -j${JOBS} || { echo "gcc make failed"; return 1; }
    make install || return 1
    return 0
}

function main()
{
#    build_gcc_prerequist || { echo "prerequist build failed."; exit 1; }
    build_gcc || { echo "build gcc failed"; exit 1; }
}

main "$@"
