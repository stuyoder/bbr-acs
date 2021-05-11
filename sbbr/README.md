# Server Base Boot Requirements - Architecture Compliance Suite
BBR specification complements the BSA specification by defining the base firmware requirements
required for out-of-box support of any BSA compatible operating system or hypervisor. These requirements are comprehensive enough
to enable booting multi-core ARM platforms while remaining minimal enough to allow for OEM and ODM innovation, and
market differentiation.

For more information, see [BBR specification](https://developer.arm.com/documentation/den0044/latest).

This release includes both UEFI Shell and OS context tests that are packaged into a bootable OS image.
The BBR test suites check for compliance against the SBBR/EBBR specification. Like the BSA tests, these tests are also delivered through two runtime executable environments:
  - UEFI Self Certification Tests (SCT)
  - Firmware Test Suite (FWTS)

## UEFI Self Certification Tests
Self-Certification Tests (SCTs) test the UEFI implementation requirements defined by SBBR/EBBR. The SCT implementation can eventually merge into the EDK2 tree and as a result, SBBR tests in these deliverables leverage those present in EDK2.

**Prerequisite** : Ensure that the system time is correct before starting SCT tests.

### Running SCT
BBR SCT tests are built as part of the test suite <br />

Running of BBR SCT tests is now automated. You can choose to skip the automated SCT tests by pressing any key when the UEFI shell prompts.

- Shell>Press any key to stop the EFI SCT running

To run SCT manually, Follow these steps:


1. `Shell>FS(X):`
- `FS(X):>cd EFI\BOOT\bbr\SCT`
- To run EBBR or SBBR tests
 `FS(X):EFI\BOOT\bbr\SCT>SCT -s <ebbr.seq/sbbr.seq>`
 - To run all tests
 `FS(X):EFI\BOOT\bbr\SCT>SCT -a -v`
 

The User can also select and run tests indviually. For information about running the tests, see [SCT User Guide](http://www.uefi.org/testtools).


## SBBR based on Firmware Test Suite
Firmware Test Suite (FWTS) is a package that is hosted by Canonical. FWTS provides tests for ACPI, SMBIOS and UEFI.
Several SBBR assertions are tested though FWTS.

### Running FWTS tests

You can choose to boot LUV OS by entering the command:

`Shell>exit`

This command loads the grub menu. Press enter to choose the option 'Linux BusyBox' that boots the OS and runs FWTS tests and OS context SBSA tests automatically. <br />

Logs are stored into the a results partition, which can be viewed on any machine after tests are run. 


## Build SCT
SCT is automatically built and packaged into ACS, but it can also be built independently. 

### 1. Getting the source 
You can get the source by simply running the `./build-scripts/get_source.sh` script from the `syscomp-bbr/scripts` directory. This will clone `edk2-test` into the directory.

### 2. Building SCT
SCT can be built one of two ways. From the same `syscomp-bbr/scripts` directory, you can run `./build-scripts/build-<es/ir>-live-image.sh` to build it along with all the ACS components. Or you can run `./build-scripts/build-sct.sh <ES/IR>` if you want to build it independently from from everything else.

The script will apply a patch to create a "BBR" build recipe in the SCT build system. It will also copy over new files to support the new tests and run/startup sequence.

The output can be found in `syscomp-bbr/scripts/edk2-test/uefi-sct/<ARCH>_SCT #(i.e. AARCH64_SCT)`



## Validation

a. Tests run on SGI-575 Reference Platforms

       i. SBBR Tests. (UEFI Shell based tests built on top of UEFI-SCT Framework)
       ii. SBBR Tests. (OS based tests built on top of FWTS Framework)


b. Known issues
UEFI-SCT Timer & reboot tests might hang. They can be recovered by resetting the system.




