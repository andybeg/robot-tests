*** Settings ***
Documentation    Destructive-пакет OpenBMC: проверка reset-action'ов и опциональный запуск перезагрузки BMC.
Resource    ../resources/openbmc_keywords.robot
Suite Setup    OpenBMC Session
Suite Teardown    Close OpenBMC Session

*** Test Cases ***
System Reset Action Is Advertised
    [Documentation]    Проверяет, что у ресурса ComputerSystem объявлено действие #ComputerSystem.Reset и доступен target для вызова.
    [Tags]    openbmc    destructive    manual
    ${systems}=    Get Collection Members    ${SYSTEMS}
    ${sample}=    Take First N Members    ${systems}    1
    ${member}=    Set Variable    ${sample}[0]
    ${system_uri}=    Get Member OData ID    ${member}
    ${resp}=    Redfish GET    ${system_uri}
    Assert Status Is Success    ${resp}
    ${payload}=    Get JSON    ${resp}
    ${actions}=    Evaluate    $payload.get("Actions", {})
    ${reset_action}=    Evaluate    $actions.get("#ComputerSystem.Reset", {})
    ${target}=    Evaluate    $reset_action.get("target", "")
    Should Not Be Empty    ${target}

BMC Reset Action Is Advertised
    [Documentation]    Проверяет, что у ресурса Manager объявлено действие #Manager.Reset и доступен target для вызова.
    [Tags]    openbmc    destructive    manual
    ${managers}=    Get Collection Members    ${MANAGERS}
    ${sample}=    Take First N Members    ${managers}    1
    ${member}=    Set Variable    ${sample}[0]
    ${manager_uri}=    Get Member OData ID    ${member}
    ${resp}=    Redfish GET    ${manager_uri}
    Assert Status Is Success    ${resp}
    ${payload}=    Get JSON    ${resp}
    ${actions}=    Evaluate    $payload.get("Actions", {})
    ${reset_action}=    Evaluate    $actions.get("#Manager.Reset", {})
    ${target}=    Evaluate    $reset_action.get("target", "")
    Should Not Be Empty    ${target}

Execute BMC Graceful Restart
    [Documentation]    Выполняет #Manager.Reset с ResetType=GracefulRestart только при OPENBMC_ALLOW_DESTRUCTIVE=true.
    [Tags]    openbmc    destructive    manual
    Skip Unless Destructive Allowed
    ${managers}=    Get Collection Members    ${MANAGERS}
    ${sample}=    Take First N Members    ${managers}    1
    ${member}=    Set Variable    ${sample}[0]
    ${manager_uri}=    Get Member OData ID    ${member}
    ${resp}=    Redfish GET    ${manager_uri}
    Assert Status Is Success    ${resp}
    ${payload}=    Get JSON    ${resp}
    ${actions}=    Evaluate    $payload.get("Actions", {})
    ${reset_action}=    Evaluate    $actions.get("#Manager.Reset", {})
    ${target}=    Evaluate    $reset_action.get("target", "")
    Should Not Be Empty    ${target}
    ${body}=    Create Dictionary    ResetType=GracefulRestart
    ${post_resp}=    Redfish POST    ${target}    ${body}
    Should Be True    ${post_resp.status_code} in [200, 202, 204]
    Sleep    ${WAIT_AFTER_RESET_SECONDS}
