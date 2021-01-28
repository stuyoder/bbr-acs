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

#------------------------------------------
# Generate the disk image for busybox boot
#------------------------------------------

#variables for image generation
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
TOP_DIR=`pwd`
PLATDIR=${TOP_DIR}/output
OUTDIR=${PLATDIR}
GRUB_FS_CONFIG_FILE=${TOP_DIR}/build-scripts/configs/grub.cfg
EFI_CONFIG_FILE=${TOP_DIR}/build-scripts/configs/startup.nsh
BSA_CONFIG_FILE=${TOP_DIR}/build-scripts/configs/bsa.nsh
BLOCK_SIZE=512
SEC_PER_MB=$((1024*2))
GRUB_PATH=grub
UEFI_SHELL_PATH=edk2/Build/Shell/RELEASE_GCC5/AARCH64/
BSA_EFI_PATH=edk2/Build/Shell/DEBUG_GCC49/AARCH64/

create_cfgfiles ()
{
    local fatpart_name="$1"

    mcopy -i  $fatpart_name -o ${GRUB_FS_CONFIG_FILE} ::/grub.cfg
    mcopy -i  $fatpart_name -o ${EFI_CONFIG_FILE}     ::/EFI/BOOT/startup.nsh
    mcopy -i  $fatpart_name -o ${BSA_CONFIG_FILE}    ::/EFI/BOOT/bsa/bsa.nsh

}

create_fatpart ()
{
    local fatpart_name="$1"  #Name of the FAT partition disk image
    local fatpart_size="$2"  #FAT partition size (in 512-byte blocks)

    dd if=/dev/zero of=$fatpart_name bs=$BLOCK_SIZE count=$fatpart_size
    mkfs.vfat $fatpart_name
    mmd -i $fatpart_name ::/EFI
    mmd -i $fatpart_name ::/EFI/BOOT
    mmd -i $fatpart_name ::/grub
    mmd -i $fatpart_name ::/EFI/BOOT/bsa
    mmd -i $fatpart_name ::/bsa_results
    mcopy -i $fatpart_name bootaa64.efi ::/EFI/BOOT
    mcopy -i $fatpart_name Shell.efi ::/EFI/BOOT
    mcopy -i $fatpart_name $OUTDIR/Image ::/
    mcopy -i $fatpart_name $PLATDIR/ramdisk-busybox.img  ::/
    mcopy -i $fatpart_name Bsa.efi ::/EFI/BOOT/bsa
    echo "FAT partition image created"
}

create_diskimage ()
{
    local image_name="$1"
    local part_start="$2"
    local fatpart_size="$3"

    (echo n; echo 1; echo $part_start; echo +$((fatpart_size-1));\
    echo 0700; echo w; echo y) | gdisk $image_name
    (echo n; echo 2; echo $((part_start+fatpart_size)); echo +$((fatpart_size-1));\
    echo 8300; echo w; echo y) | gdisk $image_name
}

prepare_disk_image ()
{
    echo
    echo
    echo "-------------------------------------"
    echo "Preparing disk image for busybox boot"
    echo "-------------------------------------"

    pushd $TOP_DIR/$GRUB_PATH/output
    local IMG_BB=grub-busybox.img
    local FAT_SIZE_MB=512
    local PART_START=$((1*SEC_PER_MB))
    local FAT_SIZE=$((FAT_SIZE_MB*SEC_PER_MB))

    rm -f $PLATDIR/$IMG_BB
    cp grubaa64.efi bootaa64.efi
    cp $TOP_DIR/$UEFI_SHELL_PATH/Shell_EA4BB293-2D7F-4456-A681-1F22F42CD0BC.efi Shell.efi
    cp $TOP_DIR/$BSA_EFI_PATH/Bsa.efi Bsa.efi
    grep -q -F 'mtools_skip_check=1' ~/.mtoolsrc || echo "mtools_skip_check=1" >> ~/.mtoolsrc

    #Package images for Busybox
    rm -f $IMG_BB
    dd if=/dev/zero of=part_table bs=$BLOCK_SIZE count=$PART_START

    #Space for partition table at the top
    cat part_table > $IMG_BB

    #Create fat partition
    create_fatpart "fat_part" $FAT_SIZE
    create_cfgfiles "fat_part"
    cat fat_part >> $IMG_BB

    #Space for backup partition table at the bottom (1M)
    cat part_table >> $IMG_BB

    # create disk image and copy into output folder
    create_diskimage $IMG_BB $PART_START $FAT_SIZE
    cp $IMG_BB $PLATDIR

    #remove intermediate files
    rm -f part_table
    rm -f fat_part

    echo "Completed preparation of disk image for busybox boot"
    echo "----------------------------------------------------"
}

#prepare the disk image
prepare_disk_image
