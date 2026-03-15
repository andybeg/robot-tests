*** Settings ***
Documentation    UI-проверки сайта Sber в headless-браузере: базовая загрузка страницы и наличие ключевых контролов интерфейса.
Library    SeleniumLibrary
Variables    ../config/ui_config.py
Suite Setup       Set Selenium Timeout    ${SELENIUM_TIMEOUT}
Test Teardown     Close Browser
Suite Teardown    Close All Browsers

*** Test Cases ***
Sber UI Smoke Headless
    [Documentation]    Проверяет, что главная страница открывается в headless-режиме, URL соответствует ожидаемым доменам, а заголовок страницы не пустой.
    # Открываем главную страницу в headless-режиме со стабильным размером окна.
    Open Browser    ${BASE_URL}    browser=${BROWSER}    options=${BROWSER_OPTIONS}
    # Ждем загрузку DOM перед проверкой метаданных страницы.
    Wait Until Page Contains Element    css:body    15s
    # Сайт может редиректить на sberbank.com, поэтому допускаем оба домена.
    ${current_url}=    Get Location
    Should Match Regexp    ${current_url}    ${ALLOWED_URL_REGEXP}
    # Заголовок страницы должен быть непустым (базовая UX-проверка).
    ${title}=    Get Title
    Should Not Be Empty    ${title}

Sber UI Controls Presence
    [Documentation]    Проверяет базовый состав UI: достаточное количество ссылок, наличие кнопок и элементов формы на стартовой странице.
    # Проверяем, что на странице есть ссылки, кнопки и элементы форм.
    Open Browser    ${BASE_URL}    browser=${BROWSER}    options=${BROWSER_OPTIONS}
    Wait Until Page Contains Element    css:body    15s

    ${anchors}=    Get Element Count    css:a[href]
    Should Be True    ${anchors} >= ${MIN_ANCHORS_COUNT}

    ${buttons}=    Get Element Count    css:button
    Should Be True    ${buttons} >= ${MIN_BUTTONS_COUNT}

    ${form_controls}=    Execute JavaScript    return document.querySelectorAll('input, select, textarea').length;
    Should Be True    ${form_controls} >= ${MIN_FORM_CONTROLS_COUNT}
