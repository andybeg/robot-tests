*** Settings ***
Documentation    Smoke-пакет OpenBMC Redfish: проверяет доступность service root, коллекций Systems/Managers/Chassis и ключевых сервисов.
Resource    ../resources/openbmc_keywords.robot
Suite Setup    OpenBMC Session
Suite Teardown    Close OpenBMC Session

*** Test Cases ***
Service Root Is Available
    [Documentation]    Проверяет, что сервис Redfish доступен и содержит базовые ссылки на Systems, Managers и Chassis.
    [Tags]    openbmc    smoke    redfish
    ${resp}=    Redfish GET    ${SERVICE_ROOT}
    Assert Status Is Success    ${resp}
    ${payload}=    Get JSON    ${resp}
    Assert Key Exists    ${payload}    RedfishVersion
    Assert Key Exists    ${payload}    Systems
    Assert Key Exists    ${payload}    Managers
    Assert Key Exists    ${payload}    Chassis

Systems Collection Is Available
    [Documentation]    Проверяет коллекцию систем и валидирует базовые поля каждой выбранной системы: Id, Name, PowerState/Health (если присутствуют).
    [Tags]    openbmc    smoke    redfish
    ${members}=    Get Collection Members    ${SYSTEMS}
    ${sample}=    Take First N Members    ${members}    ${MAX_MEMBERS_TO_VALIDATE}
    FOR    ${member}    IN    @{sample}
        ${member_uri}=    Get Member OData ID    ${member}
        ${resp}=    Redfish GET    ${member_uri}
        Assert Status Is Success    ${resp}
        ${payload}=    Get JSON    ${resp}
        Assert Key Exists    ${payload}    Id
        Assert Key Exists    ${payload}    Name
        Assert Optional State    ${payload}
        Assert Optional Health    ${payload}
    END

Managers Collection Is Available
    [Documentation]    Проверяет коллекцию менеджеров BMC и валидирует обязательные поля manager-ресурсов.
    [Tags]    openbmc    smoke    redfish
    ${members}=    Get Collection Members    ${MANAGERS}
    ${sample}=    Take First N Members    ${members}    ${MAX_MEMBERS_TO_VALIDATE}
    FOR    ${member}    IN    @{sample}
        ${member_uri}=    Get Member OData ID    ${member}
        ${resp}=    Redfish GET    ${member_uri}
        Assert Status Is Success    ${resp}
        ${payload}=    Get JSON    ${resp}
        Assert Key Exists    ${payload}    Id
        Assert Key Exists    ${payload}    Name
        Assert Key Exists    ${payload}    ManagerType
    END

Chassis Collection Is Available
    [Documentation]    Проверяет коллекцию шасси и валидирует базовые атрибуты каждого ресурса шасси.
    [Tags]    openbmc    smoke    redfish
    ${members}=    Get Collection Members    ${CHASSIS}
    ${sample}=    Take First N Members    ${members}    ${MAX_MEMBERS_TO_VALIDATE}
    FOR    ${member}    IN    @{sample}
        ${member_uri}=    Get Member OData ID    ${member}
        ${resp}=    Redfish GET    ${member_uri}
        Assert Status Is Success    ${resp}
        ${payload}=    Get JSON    ${resp}
        Assert Key Exists    ${payload}    Id
        Assert Key Exists    ${payload}    Name
        Assert Optional Health    ${payload}
    END

Core Services Are Reachable
    [Documentation]    Проверяет доступность SessionService, AccountService и UpdateService. Для платформенных ограничений допускает Forbidden/Unauthorized.
    [Tags]    openbmc    smoke    redfish
    ${session_resp}=    Redfish GET    ${SESSION_SERVICE}
    Assert Status Is Existing Or Forbidden    ${session_resp}
    ${account_resp}=    Redfish GET    ${ACCOUNT_SERVICE}
    Assert Status Is Existing Or Forbidden    ${account_resp}
    ${update_resp}=    Redfish GET    ${UPDATE_SERVICE}
    Assert Status Is Existing Or Forbidden    ${update_resp}
