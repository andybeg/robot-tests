*** Settings ***
Documentation    Regression-пакет OpenBMC Redfish: расширенные проверки сети, сенсоров, логов и служебных сервисов.
Resource    ../resources/openbmc_keywords.robot
Suite Setup    OpenBMC Session
Suite Teardown    Close OpenBMC Session

*** Test Cases ***
Validate Managers Ethernet Interfaces
    [Documentation]    Проверяет EthernetInterfaces менеджеров и валидирует состояние линков на доступных интерфейсах.
    [Tags]    openbmc    regression    network
    ${mgr_members}=    Get Collection Members    ${MANAGERS}
    ${mgr_sample}=    Take First N Members    ${mgr_members}    ${MAX_MEMBERS_TO_VALIDATE}
    FOR    ${manager}    IN    @{mgr_sample}
        ${manager_uri}=    Get Member OData ID    ${manager}
        ${if_resp}=    Redfish GET    ${manager_uri}/EthernetInterfaces
        Assert Status Is Existing Or Forbidden    ${if_resp}
        IF    ${if_resp.status_code} in [200, 201, 202, 204]
            ${if_payload}=    Get JSON    ${if_resp}
            ${if_members}=    Evaluate    $if_payload.get("Members", [])
            ${if_sample}=    Take First N Members    ${if_members}    ${MAX_MEMBERS_TO_VALIDATE}
            FOR    ${iface}    IN    @{if_sample}
                ${iface_uri}=    Get Member OData ID    ${iface}
                ${iface_resp}=    Redfish GET    ${iface_uri}
                Assert Status Is Success    ${iface_resp}
                ${iface_json}=    Get JSON    ${iface_resp}
                ${link_status}=    Evaluate    $iface_json.get("LinkStatus", "Unknown")
                Should Contain    ${ALLOWED_LINK_STATES}    ${link_status}
            END
        END
    END

Validate Chassis Thermal And Power
    [Documentation]    Проверяет доступность эндпоинтов Thermal и Power для каждого выбранного шасси.
    [Tags]    openbmc    regression    sensors
    ${chassis_members}=    Get Collection Members    ${CHASSIS}
    ${chassis_sample}=    Take First N Members    ${chassis_members}    ${MAX_MEMBERS_TO_VALIDATE}
    FOR    ${chassis}    IN    @{chassis_sample}
        ${chassis_uri}=    Get Member OData ID    ${chassis}
        ${thermal_resp}=    Redfish GET    ${chassis_uri}/Thermal
        Assert Status Is Existing Or Forbidden    ${thermal_resp}
        ${power_resp}=    Redfish GET    ${chassis_uri}/Power
        Assert Status Is Existing Or Forbidden    ${power_resp}
    END

Validate Log Services And Entries
    [Documentation]    Проверяет LogServices менеджеров и доступность коллекций Entries для каждого найденного log service.
    [Tags]    openbmc    regression    logs
    ${mgr_members}=    Get Collection Members    ${MANAGERS}
    ${mgr_sample}=    Take First N Members    ${mgr_members}    ${MAX_MEMBERS_TO_VALIDATE}
    FOR    ${manager}    IN    @{mgr_sample}
        ${manager_uri}=    Get Member OData ID    ${manager}
        ${log_services_resp}=    Redfish GET    ${manager_uri}/LogServices
        Assert Status Is Existing Or Forbidden    ${log_services_resp}
        IF    ${log_services_resp.status_code} in [200, 201, 202, 204]
            ${log_services_json}=    Get JSON    ${log_services_resp}
            ${log_services}=    Evaluate    $log_services_json.get("Members", [])
            ${ls_sample}=    Take First N Members    ${log_services}    ${MAX_MEMBERS_TO_VALIDATE}
            FOR    ${ls}    IN    @{ls_sample}
                ${ls_uri}=    Get Member OData ID    ${ls}
                ${entries_resp}=    Redfish GET    ${ls_uri}/Entries
                Assert Status Is Existing Or Forbidden    ${entries_resp}
            END
        END
    END

Validate Event And Task Services
    [Documentation]    Проверяет доступность EventService и TaskService для текущей реализации OpenBMC.
    [Tags]    openbmc    regression    services
    ${event_resp}=    Redfish GET    ${EVENT_SERVICE}
    Assert Status Is Existing Or Forbidden    ${event_resp}
    ${task_resp}=    Redfish GET    ${TASK_SERVICE}
    Assert Status Is Existing Or Forbidden    ${task_resp}

Validate Telemetry Service If Present
    [Documentation]    Проверяет доступность TelemetryService. Если сервис ограничен политиками, допускает 401/403.
    [Tags]    openbmc    regression    telemetry
    ${telemetry_resp}=    Redfish GET    ${TELEMETRY_SERVICE}
    Assert Status Is Existing Or Forbidden    ${telemetry_resp}
