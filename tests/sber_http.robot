*** Settings ***
Documentation    Набор HTTP-проверок для sber.ru/sberbank.com: доступность, SEO endpoint'ы, заголовки безопасности, внутренние ссылки и время ответа.
Library    RequestsLibrary
Library    String
Library    ../libraries/site_analyzer.py
Variables    ../config/http_config.py

*** Test Cases ***
Sber HTTP Smoke
    [Documentation]    Базовый smoke: проверяет, что главная страница отвечает с допустимым HTTP-статусом. При проблемах с основным доменом использует fallback.
    # Быстрая проверка доступности с fallback-доменом для устойчивости.
    ${resp}=    Resolve Sber Response    ${HOMEPAGE_PATH}
    Validate Response Code    ${resp}

Sber HTTP Deep Validation
    [Documentation]    Глубокая проверка главной страницы: валидирует конечный URL после редиректов, тип контента и доступность robots.txt.
    # 1) Проверяем ответ главной страницы и итоговый URL после редиректов.
    ${home_resp}=    Resolve Sber Response    ${HOMEPAGE_PATH}
    Validate Response Code    ${home_resp}
    Should Match Regexp    ${home_resp.url}    ${ALLOWED_URL_REGEXP}

    # 2) Проверяем, что контент похож на HTML-страницу.
    ${content_type}=    Evaluate    $home_resp.headers.get("Content-Type", "")
    ${content_type_lower}=    Convert To Lower Case    ${content_type}
    Should Contain    ${content_type_lower}    text/html
    Should Not Be Empty    ${home_resp.text}

    # 3) Проверяем, что robots endpoint доступен и не пустой.
    ${robots_resp}=    Resolve Sber Response    ${ROBOTS_PATH}
    Validate Response Code    ${robots_resp}
    Should Not Be Empty    ${robots_resp.text}

Sber SEO Endpoints Validation
    [Documentation]    Проверяет SEO-точки: robots.txt и sitemap.xml. Убеждается, что ответы непустые и соответствуют ожидаемому формату.
    # Проверяем, что robots.txt и sitemap.xml доступны.
    ${robots_resp}=    Resolve Sber Response    ${ROBOTS_PATH}
    Validate Response Code    ${robots_resp}
    Should Not Be Empty    ${robots_resp.text}
    ${robots_text_lower}=    Convert To Lower Case    ${robots_resp.text}
    ${robots_has_signature}=    Evaluate    ("user-agent" in $robots_text_lower) or ("support id" in $robots_text_lower)
    Should Be True    ${robots_has_signature}

    ${sitemap_resp}=    Resolve Sber Response    ${SITEMAP_PATH}
    Validate Response Code    ${sitemap_resp}
    Should Not Be Empty    ${sitemap_resp.text}
    ${sitemap_content_type}=    Evaluate    $sitemap_resp.headers.get("Content-Type", "")
    ${sitemap_content_type}=    Convert To Lower Case    ${sitemap_content_type}
    Should Match Regexp    ${sitemap_content_type}    (xml|text)

Sber Security Headers Validation
    [Documentation]    Проверяет обязательные и рекомендованные security-заголовки на главной странице. В режиме anti-bot выполняет мягкую проверку с предупреждением.
    # Проверяем обязательные и рекомендованные security-заголовки.
    ${resp}=    Resolve Sber Response    ${HOMEPAGE_PATH}
    Validate Response Code    ${resp}
    ${is_blocked}=    Is Blocked Response    ${resp.text}

    IF    ${is_blocked}
        Log    Получена антибот-страница, строгую проверку security-заголовков пропускаем.    WARN
    ELSE
        ${missing_required}=    Get Missing Headers    ${resp.headers}    ${SECURITY_HEADERS_REQUIRED}
        Should Be Empty    ${missing_required}
    END

    ${missing_recommended}=    Get Missing Headers    ${resp.headers}    ${SECURITY_HEADERS_RECOMMENDED}
    Log    Отсутствующие рекомендованные заголовки: ${missing_recommended}    WARN

Sber Internal Links Validation
    [Documentation]    Извлекает внутренние ссылки со стартовой страницы и проверяет их доступность. Количество и глубина проверки ограничены конфигом.
    # Собираем и проверяем часть внутренних ссылок со стартовой страницы.
    ${resp}=    Resolve Sber Response    ${HOMEPAGE_PATH}
    Validate Response Code    ${resp}
    ${is_blocked}=    Is Blocked Response    ${resp.text}
    ${links}=    Extract Internal Links    ${resp.text}    ${resp.url}    ${ALLOWED_DOMAINS}    ${MAX_LINKS_TO_CHECK}
    ${links_count}=    Get Length    ${links}
    IF    ${is_blocked}
        Should Be True    ${links_count} >= 1
        Log    Получена антибот-страница, доступно ограниченное число ссылок для проверки.    WARN
    ELSE
        Should Be True    ${links_count} >= ${MIN_INTERNAL_LINKS}
    END

    FOR    ${link}    IN    @{links}
        ${link_status}    ${link_resp}=    Run Keyword And Ignore Error    GET    ${link}    expected_status=any    timeout=${REQUEST_TIMEOUT_SECONDS}
        IF    '${link_status}' == 'PASS'
            Validate Response Code    ${link_resp}
        ELSE
            Fail    Ссылка недоступна: ${link}
        END
    END

Sber Response Time Validation
    [Documentation]    Контроль производительности: время ответа главной страницы должно быть меньше порога MAX_HOME_RESPONSE_SECONDS.
    # Проверяем, что время ответа домашней страницы укладывается в порог.
    ${resp}=    Resolve Sber Response    ${HOMEPAGE_PATH}
    Validate Response Code    ${resp}
    ${elapsed}=    Evaluate    $resp.elapsed.total_seconds()
    Should Be True    ${elapsed} <= ${MAX_HOME_RESPONSE_SECONDS}

*** Keywords ***
Resolve Sber Response
    [Arguments]    ${path}
    ${status}    ${resp}=    Run Keyword And Ignore Error    GET    ${PRIMARY_URL}${path}    expected_status=any    timeout=${REQUEST_TIMEOUT_SECONDS}
    IF    '${status}' == 'PASS'
        RETURN    ${resp}
    END
    Log    Основной домен недоступен, используем fallback-домен.    WARN
    ${resp}=    GET    ${FALLBACK_URL}${path}    expected_status=any    timeout=${REQUEST_TIMEOUT_SECONDS}
    RETURN    ${resp}

Validate Response Code
    [Arguments]    ${resp}
    Should Be True    ${resp.status_code} in ${ALLOWED_STATUS_CODES}

Is Blocked Response
    [Arguments]    ${text}
    ${text_lower}=    Convert To Lower Case    ${text}
    ${is_blocked}=    Evaluate    ("support id" in $text_lower) or ("сертификат" in $text_lower)
    RETURN    ${is_blocked}
