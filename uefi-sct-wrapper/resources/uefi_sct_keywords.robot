*** Settings ***
Library    Process
Library    OperatingSystem
Library    BuiltIn
Library    Collections
Variables    ../config/uefi_sct_config.py

*** Keywords ***
Prepare SCT Workspace
    Create Directory    ${SCT_RESULTS_DIR}

Assert SCT Command Is Configured
    Should Not Be Empty
    ...    ${SCT_COMMAND}
    ...    msg=Set UEFI_SCT_COMMAND with the command that runs UEFI SCT (for example via QEMU/IPMI/serial harness).

Execute System Configuration Test
    [Documentation]    Runs external UEFI SCT command and writes stdout/stderr to files.
    ${result}=    Run Process
    ...    bash
    ...    -lc
    ...    ${SCT_COMMAND}
    ...    cwd=${SCT_WORKDIR}
    ...    timeout=${SCT_COMMAND_TIMEOUT_SECONDS}s
    ...    stdout=${SCT_STDOUT_FILE}
    ...    stderr=${SCT_STDERR_FILE}
    RETURN    ${result}

Validate SCT Exit Code
    [Arguments]    ${result}
    ${is_allowed}=    Evaluate    str($result.rc) in $SCT_EXPECTED_EXIT_CODES
    Should Be True
    ...    ${is_allowed}
    ...    msg=Unexpected SCT exit code: ${result.rc}. Allowed: ${SCT_EXPECTED_EXIT_CODES}

Validate SCT Summary
    [Arguments]    ${result}
    ${stdout_text}=    Get File    ${SCT_STDOUT_FILE}
    ${stderr_text}=    Get File    ${SCT_STDERR_FILE}
    ${combined}=    Catenate    SEPARATOR=\n    ${stdout_text}    ${stderr_text}
    IF    ${SCT_REQUIRE_NONEMPTY_LOG}
        Should Not Be Empty    ${combined}    msg=SCT logs are empty. Check launcher command and transport.
    END
    Should Match Regexp
    ...    ${combined}
    ...    ${SCT_SUMMARY_REGEX}
    ...    msg=SCT summary is not found by regex: ${SCT_SUMMARY_REGEX}

Validate Required Artifacts
    FOR    ${artifact}    IN    @{SCT_REQUIRED_ARTIFACTS}
        File Should Exist    ${artifact}
    END

Log SCT Output Paths
    Log To Console    SCT stdout: ${SCT_STDOUT_FILE}
    Log To Console    SCT stderr: ${SCT_STDERR_FILE}
