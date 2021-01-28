## Bootable live image

Scripts are used to create a bootable live image which will test BSA and FWTS automatically.

### Prerequisite

 - Tested in Ubuntu 16.04 & 18.04 64 bit machines
 - User should have **sudo** privilege to install tools required for build
 - User should have access to internal [BSA](https://ap-gerrit-1.ap01.arm.com/admin/repos/avk/syscomp_bsa) repo

### Steps to run

 1. Clone [BBR](https://ap-gerrit-1.ap01.arm.com/admin/repos/avk/syscomp\_bbr) repo.
 2. cd syscomp\_bbr/scripts
 3. _./build-scripts/get\_source.sh_ (Download source & tools required , give **sudo** password to install  depended tools )
 4. _./build-scripts/build-all.sh_ (Build)
 5. _./build-scripts/make\_image.sh_ (Create bootable image)
 6. The bootable image **_grub-busybox.img_** will be available in **_./output_** ,if all of above steps are success.
 7. Boot it with qemu or any FVP
     * Command to boot with qemu : _sudo qemu-system-aarch64 -nographic -cpu cortex-a53 -M virt -m 1024 -bios /usr/share/qemu-efi-aarch64/QEMU\_EFI.fd -drive if=virtio,format=raw,file= (**path to image**)/grub-busybox.img_
 8. Select required option from grub selection.
- - - - - - - - - - - - - - - - - - - -

_Copyright (c) 2021, Arm Limited and Contributors. All rights reserved._

