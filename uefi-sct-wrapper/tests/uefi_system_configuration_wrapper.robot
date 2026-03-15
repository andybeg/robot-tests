*** Settings ***
Documentation    Wrapper suite for UEFI System Configuration Test (SCT).
Resource    ../resources/uefi_sct_keywords.robot
Suite Setup    Prepare SCT Workspace

*** Test Cases ***
UEFI SCT Wrapper Smoke
    [Documentation]    Runs configured SCT command and validates summary/result artifacts.
    [Tags]    uefi    sct    wrapper    smoke
    Assert SCT Command Is Configured
    ${result}=    Execute System Configuration Test
    Validate SCT Exit Code    ${result}
    Validate SCT Summary    ${result}
    Validate Required Artifacts
    Log SCT Output Paths
