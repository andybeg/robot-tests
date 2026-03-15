*** Settings ***
Documentation    Простой legacy smoke-тест UI для sber.ru: открытие главной страницы и базовая проверка заголовка.
Library    SeleniumLibrary

*** Variables ***
${URL}    https://www.sber.ru

*** Test Cases ***
Sber Main Page Opens
    [Documentation]    Проверяет доступность главной страницы в браузере и то, что title не пустой.
    Open Browser    ${URL}    chrome
    Maximize Browser Window
    Wait Until Page Contains Element    css:body    15s
    ${current_url}=    Get Location
    Should Match Regexp    ${current_url}    https?://(www\\.)?(sber\\.ru|sberbank\\.com)(/.*)?
    ${title}=    Get Title
    Should Not Be Empty    ${title}
    [Teardown]    Close Browser

