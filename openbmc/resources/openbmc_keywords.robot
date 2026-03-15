*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    BuiltIn
Variables    ../config/openbmc_config.py

*** Keywords ***
OpenBMC Session
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    Create Session    bmc    ${BMC_BASE_URL}    auth=${BMC_AUTH}    verify=${VERIFY_TLS}    timeout=${REQUEST_TIMEOUT_SECONDS}    headers=${headers}

Close OpenBMC Session
    Delete All Sessions

Redfish GET
    [Arguments]    ${path}
    ${resp}=    GET On Session    bmc    ${path}    expected_status=any
    RETURN    ${resp}

Redfish POST
    [Arguments]    ${path}    ${body}
    ${resp}=    POST On Session    bmc    ${path}    json=${body}    expected_status=any
    RETURN    ${resp}

Assert Status Is Success
    [Arguments]    ${resp}
    Should Be True    ${resp.status_code} in [200, 201, 202, 204]

Assert Status Is Existing Or Forbidden
    [Arguments]    ${resp}
    Should Be True    ${resp.status_code} in [200, 201, 202, 204, 401, 403]

Get JSON
    [Arguments]    ${resp}
    ${payload}=    Evaluate    $resp.json()
    RETURN    ${payload}

Get Collection Members
    [Arguments]    ${collection_path}
    ${resp}=    Redfish GET    ${collection_path}
    Assert Status Is Success    ${resp}
    ${payload}=    Get JSON    ${resp}
    ${members}=    Evaluate    $payload.get("Members", [])
    ${count}=    Get Length    ${members}
    Should Be True    ${count} >= ${MIN_COLLECTION_SIZE}
    RETURN    ${members}

Get Member OData ID
    [Arguments]    ${member}
    ${odata_id}=    Evaluate    $member.get("@odata.id", "")
    Should Not Be Empty    ${odata_id}
    RETURN    ${odata_id}

Assert Key Exists
    [Arguments]    ${payload}    ${key}
    Dictionary Should Contain Key    ${payload}    ${key}

Assert Optional Health
    [Arguments]    ${payload}
    ${status}=    Evaluate    $payload.get("Status", {})
    ${health}=    Evaluate    $status.get("Health", "")
    IF    '${health}' != ''
        Should Contain    ${ALLOWED_HEALTH_STATES}    ${health}
    END

Assert Optional State
    [Arguments]    ${payload}
    ${state}=    Evaluate    $payload.get("PowerState", "")
    IF    '${state}' != ''
        Should Contain    ${ALLOWED_POWER_STATES}    ${state}
    END

Take First N Members
    [Arguments]    ${members}    ${limit}
    ${size}=    Get Length    ${members}
    ${end}=    Evaluate    min($size, int($limit))
    ${sample}=    Evaluate    $members[:$end]
    RETURN    ${sample}

Skip Unless Destructive Allowed
    Pass Execution If    not ${ALLOW_DESTRUCTIVE}    Пропуск destructive-теста: OPENBMC_ALLOW_DESTRUCTIVE=false
