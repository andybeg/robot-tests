*** Settings ***
Documentation    Простой legacy HTTP smoke-тест: проверка доступности стартовой страницы Sber по статус-коду.
Library    RequestsLibrary

*** Test Cases ***
Sber Responds 200 Or 301
    [Documentation]    Проверяет, что запрос к главной странице возвращает один из ожидаемых кодов: 200, 301 или 302.
    Create Session    sber    https://www.sber.ru
    ${resp}=    GET On Session    sber    /
    Should Contain    200 301 302    ${resp.status_code}

