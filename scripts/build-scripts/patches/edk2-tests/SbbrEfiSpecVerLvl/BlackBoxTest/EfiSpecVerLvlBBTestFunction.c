/*++
  The material contained herein is not a license, either
  expressly or impliedly, to any intellectual property owned
  or controlled by any of the authors or developers of this
  material or to any contribution thereto. The material
  contained herein is provided on an "AS IS" basis and, to the
  maximum extent permitted by applicable law, this information
  is provided AS IS AND WITH ALL FAULTS, and the authors and
  developers of this material hereby disclaim all other
  warranties and conditions, either express, implied or
  statutory, including, but not limited to, any (if any)
  implied warranties, duties or conditions of merchantability,
  of fitness for a particular purpose, of accuracy or
  completeness of responses, of results, of workmanlike
  effort, of lack of viruses and of lack of negligence, all
  with regard to this material and any contribution thereto.
  Designers must not rely on the absence or characteristics of
  any features or instructions marked "reserved" or
  "undefined." The Unified EFI Forum, Inc. reserves any
  features or instructions so marked for future definition and
  shall have no responsibility whatsoever for conflicts or
  incompatibilities arising from future changes to them. ALSO,
  THERE IS NO WARRANTY OR CONDITION OF TITLE, QUIET ENJOYMENT,
  QUIET POSSESSION, CORRESPONDENCE TO DESCRIPTION OR
  NON-INFRINGEMENT WITH REGARD TO THE TEST SUITE AND ANY
  CONTRIBUTION THERETO.

  IN NO EVENT WILL ANY AUTHOR OR DEVELOPER OF THIS MATERIAL OR
  ANY CONTRIBUTION THERETO BE LIABLE TO ANY OTHER PARTY FOR
  THE COST OF PROCURING SUBSTITUTE GOODS OR SERVICES, LOST
  PROFITS, LOSS OF USE, LOSS OF DATA, OR ANY INCIDENTAL,
  CONSEQUENTIAL, DIRECT, INDIRECT, OR SPECIAL DAMAGES WHETHER
  UNDER CONTRACT, TORT, WARRANTY, OR OTHERWISE, ARISING IN ANY
  WAY OUT OF THIS OR ANY OTHER AGREEMENT RELATING TO THIS
  DOCUMENT, WHETHER OR NOT SUCH PARTY HAD ADVANCE NOTICE OF
  THE POSSIBILITY OF SUCH DAMAGES.

  Copyright 2006 - 2016 Unified EFI, Inc. All
  Rights Reserved, subject to all existing rights in all
  matters included within this Test Suite, to which United
  EFI, Inc. makes no claim of right.

  Copyright (c) 2016, ARM Ltd. All rights reserved.<BR>

--*/
/*++

Module Name:

  EfiSpecVerLvlBBTestFunction.c

Abstract:

  Test case definitions for EfiSpecVerLvl test.

--*/

#include <Library/ArmLib.h>

#include "EfiSpecVerLvlBBTestMain.h"
#include "Guid.h"
#include "SctLib.h"
#include "EfiSpecVerLvlBBTestFunction.h"

/** Entrypoint for EFI Specification Version Level Test.
 *
 *  @param This a pointer of EFI_BB_TEST_PROTOCOL.
 *  @param ClientInterface a pointer to the interface to be tested.
 *  @param TestLevel test "thoroughness" control.
 *  @param SupportHandle a handle containing protocols required.
 *  @return EFI_SUCCESS Finish the test successfully.
 */

//
// SBBR 3.1
//

EFI_STATUS
BBTestEfiSpecVerLvlTest (
  IN EFI_BB_TEST_PROTOCOL               *This,
  IN VOID                               *ClientInterface,
  IN EFI_TEST_LEVEL                     TestLevel,
  IN EFI_HANDLE                         SupportHandle
  )
{

  EFI_STANDARD_TEST_LIBRARY_PROTOCOL    *StandardLib;
  EFI_STATUS                            Status;
  UINTN                                 CurHrRev;

  // Get the Standard Library Interface
  Status = gtBS->HandleProtocol (
              SupportHandle,
              &gEfiStandardTestLibraryGuid,
              (VOID **) &StandardLib
              );
  if (EFI_ERROR (Status)) {
    return Status;
  }

  CurHrRev = gtBS->Hdr.Revision; // Reading revision of the EFI Specification.

  // Check if EFI Specification version is less than 2.7
  if (gtBS->Hdr.Revision < EFI_2_70_SYSTEM_TABLE_REVISION){
    StandardLib->RecordAssertion (
                StandardLib,
                EFI_TEST_ASSERTION_FAILED,
                gTestGenericFailureGuid,
                L"EFI Specification Version is below 2.7",
                L"%a:%d:Current EFI Header Rev=0x%X",
                __FILE__,
                __LINE__,
                CurHrRev
                );
    return EFI_INCOMPATIBLE_VERSION;
  } else {
    StandardLib->RecordAssertion (
                StandardLib,
                EFI_TEST_ASSERTION_PASSED,
                gEfiSpecVerLvlAssertion01Guid,
                L"TestEfiSpecVerLvl",
                L"%a:%d:Current EFI Header Rev=0x%X",
                __FILE__,
                __LINE__,
                CurHrRev
                );

    return EFI_SUCCESS;
  }
}
