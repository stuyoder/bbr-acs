#Base Boot Requirements :  Architecture Compliance Suite
The Base Boot Requirements (BBR) specification provides some boot recipes. These recipes accommodate the different standards and boot firmware implementations that are used by a broader range of operating systems and hypervisors.
BBR specification complements the BSA specification by defining the base firmware requirements required for out-of-box support of any BSA compatible operating system or hypervisor.

For more information, see [BBR specification](https://developer.arm.com/documentation/den0044/latest).

This release includes both UEFI Shell and OS context tests that are packaged into a bootable Linux OS image. The BBR test suites check for compliance against the BBR specification. Like the BSA tests, these tests are also delivered through two runtime executable environments:

UEFI Self Certification Tests
BBR based on Firmware Test Suite


**Note for ALPA Release:** This repo contains scripts and steps to build live ACS images for ES and IR bands. These shall be moved to the SystemReady repository in BETA release, which shall be the front facing repo for the Arm Partners.

## Release details
 - Code Quality: REL v1.0 ALPHA
 - **The latest pre-built release of ACS for ES is available for download here: (add link)**
 - **The latest pre-built release of ACS for IR is available for download here: (add link)**
 - The BSA tests are written for version 1.0 of the BSA specification.
 - The BBR tests are written for version 1.0 of the BBR specification.
 - The compliance suite is not a substitute for design verification.
 - To review the ACS logs, Arm licensees can contact Arm directly through their partner managers.



## Bootable live image

Build scripts in this repo create a bootable live image which will test BSA, SCT and FWTS automatically.

### Prerequisite

 - Tested in Ubuntu 16.04 & 18.04 64 bit machines
 - User should have **sudo** privilege to install tools required for build

### Steps to build ACS live image

 1. Clone [BBR](https://ap-gerrit-1.ap01.arm.com/admin/repos/avk/syscomp_bbr) repo.
 Note: Please request for permissions if you don't have access.
 2. cd syscomp_bbr/scripts
 3. ./build-scripts/get_source.sh
 (Downloads source & tools required , give **sudo** password to install  depended tools )

 4. To build the ACS live image, execute **one** of the below steps
 To build IR ACS live image, execute
 ./build-scripts/build-ir-live-image.sh
 (Builds IR ACS live Image)

 OR

 To build ES ACS live image, execute
 ./build-scripts/build-es-live-image.sh
 (Builds ES ACS live Image)

 5. The bootable image will be available in **./output** , if all of above steps are success.
 For IR : ir_acs_live_image.img
 For ES : es_acs_live_image.img

### Verification of the ES Image on Qemu
Command to boot with qemu :
    sudo qemu-system-aarch64 -nographic -cpu cortex-a53 -M virt -m 1024 -bios (**path to QEMU_EFI**)/qemu-efi/QEMU_EFI.fd -drive if=virtio,format=raw,file=(**path to image**)/es_acs_live_image.img

   Note: qemu for aarch64 must be installed  before running above command  by `sudo apt-get install qemu-utils qemu-efi qemu-system-arm`

### Verification of the ES Image on Fixed Virtual Platform (FVP) environment

The steps for running the ES ACS on an FVP are

  - Modify 'run_model.sh' to add a model command argument that loads 'es_acs_live_image.img' as a virtual disk image. For example, add

    `bp.virtioblockdevice.image path=<path to es image>/es_acs_live_image.img`

    to your model options.
    Or,
   - To launch the FVP model with script ‘run_model.sh’ that supports -v option for virtual disk image, use the following command:
    `./run_model.sh -v <path to es imag>/es_acs_live_image.img`
- - - - - - - - - - - - - - - - - - - -

_Copyright (c) 2021, Arm Limited and Contributors. All rights reserved._
