## Bootable live image

Scripts in this repo are used to create a bootable live image which will test BSA and FWTS automatically.

### Prerequisite

 - Tested in Ubuntu 16.04 & 18.04 64 bit machines
 - User should have **sudo** privilege to install tools required for build

### Steps to build ACS live image

 1. Clone [BBR](https://ap-gerrit-1.ap01.arm.com/admin/repos/avk/syscomp_bbr) repo.
 2. cd syscomp_bbr/scripts
 3. ./build-scripts/get_source.sh 
 (Downloads source & tools required , give **sudo** password to install  depended tools )
 
 To build the ACS live image, execute **one** of the below steps (4a or 4b)
 To build IR ACS live image, execute
 4a. ./build-scripts/build-all.sh 
 (Builds IR ACS live Image)
 
 OR

 To build ES ACS live image, execute
 4a. ./build-scripts/build-all.sh 
 (Builds ES ACS live Image)
  

 5. ./build-scripts/make_image.sh (Create bootable image)
 6. The bootable image **grub-busybox.img** will be available in **./output** , if all of above steps are success.
 7. Boot it with qemu or any FVP
      * Command to boot with qemu :
    sudo qemu-system-aarch64 -nographic -cpu cortex-a53 -M virt -m 1024 -bios (**path to QEMU_EFI**)/qemu-efi/QEMU_EFI.fd -drive if=virtio,format=raw,file=(**path to image**)/grub-busybox.img

   Note: qemu for aarch64 must be installed  before running above command  by `sudo apt-get install qemu-utils qemu-efi qemu-system-arm`

 8. Select required option from grub selection.
- - - - - - - - - - - - - - - - - - - -

_Copyright (c) 2021, Arm Limited and Contributors. All rights reserved._
