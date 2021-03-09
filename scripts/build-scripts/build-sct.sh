#!/usr/bin/env bash

# Copyright (c) 2021, ARM Limited and Contributors. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# Neither the name of ARM nor the names of its contributors may be used
# to endorse or promote products derived from this software without specific
# prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

#
# This script uses the following environment variables from the variant
#
# VARIANT - build variant name
# TOP_DIR - workspace root directory
# CROSS_COMPILE - PATH to GCC including CROSS-COMPILE prefix
# PARALLELISM - number of cores to build across
# UEFI_BUILD_ENABLED - Flag to enable building UEFI
# UEFI_PATH - sub-directory containing UEFI code
# UEFI_BUILD_MODE - DEBUG or RELEASE
# UEFI_TOOLCHAIN - Toolchain supported by Linaro uefi-tools: GCC49, GCC48 or GCC47
# UEFI_PLATFORMS - List of platforms to build
# UEFI_PLAT_{platform name} - array of platform parameters:
#     - platname - the name of the platform used by the build
#     - makefile - the makefile to execute for this platform
#     - output - where to store the files in packaging phase
#     - defines - extra platform defines during the build
#     - binary - what to call the final output binary

TOP_DIR=`pwd`
UEFI_PATH=edk2
SCT_PATH=edk2-test
UEFI_TOOLCHAIN=GCC5
UEFI_BUILD_MODE=DEBUG
TARGET_ARCH=AARCH64
GCC=tools/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-
CROSS_COMPILE=$TOP_DIR/$GCC

do_build()
{
   
    pushd $TOP_DIR/$SCT_PATH
    CROSS_COMPILE_DIR=$(dirname $CROSS_COMPILE)
    PATH="$PATH:$CROSS_COMPILE_DIR"

    export EDK2_TOOLCHAIN=$UEFI_TOOLCHAIN
    export ${UEFI_TOOLCHAIN}_AARCH64_PREFIX=$CROSS_COMPILE
    local vars=
    export PACKAGES_PATH=$TOP_DIR/$UEFI_PATH
    export PYTHON_COMMAND=/usr/bin/python3
    export WORKSPACE=$TOP_DIR/$SCT_PATH/uefi-sct
    #export HOST_ARCH = `uname -m`
    #MACHINE=`uname -m`

    source $TOP_DIR/$UEFI_PATH/edksetup.sh
    make -C $TOP_DIR/$UEFI_PATH/BaseTools
    
    cp -r $TOP_DIR/build-scripts/patches/edk2-tests/SbbrBootServices uefi-sct/SctPkg/TestCase/UEFI/EFI/BootServices/
    cp -r $TOP_DIR/build-scripts/patches/edk2-tests/SbbrEfiSpecVerLvl $TOP_DIR/build-scripts/patches/edk2-tests/SbbrRequiredUefiProtocols $TOP_DIR/build-scripts/patches/edk2-tests/SbbrSmbios $TOP_DIR/build-scripts/patches/edk2-tests/SbbrSysEnvConfig uefi-sct/SctPkg/TestCase/UEFI/EFI/Generic/
    cp -r $TOP_DIR/build-scripts/patches/edk2-tests/SBBRRuntimeServices uefi-sct/SctPkg/TestCase/UEFI/EFI/RuntimeServices/
    cp $TOP_DIR/build-scripts/patches/edk2-tests/BBR_SCT.dsc uefi-sct/SctPkg/UEFI/
    cp $TOP_DIR/build-scripts/patches/edk2-tests/build_bbr.sh uefi-sct/SctPkg/

    #cp -r $TOP_DIR/build-scripts/patches/edk2-tests/sct_parser uefi-sct/sct_parser



    if ! patch -R -p1 -s -f --dry-run < $TOP_DIR/build-scripts/patches/edk2-test-bbr.patch; then
        echo "Applying SCT patch ..."
        patch  -p1  < $TOP_DIR/build-scripts/patches/edk2-test-bbr.patch
    fi

    
    
    pushd uefi-sct
    ./SctPkg/build_bbr.sh $TARGET_ARCH GCC $UEFI_BUILD_MODE

    mkdir -p ${TARGET_ARCH}_SCT/SCT
    cp -r Build/bbrSct/DEBUG_GCC5/SctPackage${TARGET_ARCH}/${TARGET_ARCH}/* ${TARGET_ARCH}_SCT/SCT/
    cp Build/bbrSct/DEBUG_GCC5/SctPackage$TARGET_ARCH/SctStartup.nsh ${TARGET_ARCH}_SCT/Startup.nsh

    # Copy the SCT Parser tool into the repo
    #cp sct_parser/* ${TARGET_ARCH}_SCT/SCT/Sequence

    popd

}

do_clean()
{
    pushd $TOP_DIR/$SCT_PATH/uefi-sct
    CROSS_COMPILE_DIR=$(dirname $CROSS_COMPILE)
    PATH="$PATH:$CROSS_COMPILE_DIR"
    source $TOP_DIR/$UEFI_PATH/edksetup.sh
    make -C $TOP_DIR/$UEFI_PATH/BaseTools clean
    rm -rf Build/bbrSct
    popd
}

do_package ()
{
    echo "Packaging sct... $VARIANT";
    # Copy binaries to output folder
    pushd $TOP_DIR
}

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $DIR/framework.sh $@
