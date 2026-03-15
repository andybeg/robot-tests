# Sber test suite (Robot Framework)

Набор тестов для сайта Sber разделен на HTTP и UI проверки.

## Файлы тестов

- `tests/sber_http.robot` — расширенные HTTP-проверки.
- `tests/sber_ui.robot` — UI-проверки в headless браузере.
- `api_smoke.robot` — legacy быстрый HTTP smoke.
- `sber_smoke.robot` — legacy быстрый UI smoke.

## Детальные описания тестов

### HTTP (`tests/sber_http.robot`)

- `Sber HTTP Smoke` — базовая проверка доступности главной страницы.
- `Sber HTTP Deep Validation` — проверка конечного URL после редиректов, типа контента и доступности `robots.txt`.
- `Sber SEO Endpoints Validation` — проверка `robots.txt` и `sitemap.xml` (доступность и непустой ответ).
- `Sber Security Headers Validation` — проверка обязательных и рекомендованных security headers.
- `Sber Internal Links Validation` — извлечение и проверка внутренних ссылок со стартовой страницы.
- `Sber Response Time Validation` — контроль времени ответа главной страницы.

### UI (`tests/sber_ui.robot`)

- `Sber UI Smoke Headless` — открытие страницы в headless-режиме, проверка URL и непустого `title`.
- `Sber UI Controls Presence` — проверка наличия ссылок, кнопок и элементов формы.

### Legacy

- `api_smoke.robot`:
  - `Sber Responds 200 Or 301` — минимальная HTTP-проверка кода ответа.
- `sber_smoke.robot`:
  - `Sber Main Page Opens` — минимальная UI-проверка открытия страницы.

## Конфигурация

### HTTP конфиг

Файл: `config/http_config.py`

Ключевые параметры:

- `PRIMARY_URL` / `FALLBACK_URL` — основной и резервный домены.
- `ALLOWED_STATUS_CODES` — допустимые HTTP-статусы.
- `MAX_HOME_RESPONSE_SECONDS` — порог времени ответа.
- `MAX_LINKS_TO_CHECK` / `MIN_INTERNAL_LINKS` — глубина и минимальный объем проверки ссылок.
- `SECURITY_HEADERS_REQUIRED` / `SECURITY_HEADERS_RECOMMENDED` — список заголовков безопасности.

### UI конфиг

Файл: `config/ui_config.py`

Ключевые параметры:

- `BASE_URL` — адрес стартовой страницы.
- `BROWSER` и `BROWSER_OPTIONS` — браузер и опции headless запуска.
- `SELENIUM_TIMEOUT` — общий timeout Selenium.
- `MIN_ANCHORS_COUNT`, `MIN_BUTTONS_COUNT`, `MIN_FORM_CONTROLS_COUNT` — минимальные пороги для UI-контролов.

## Запуск

```bash
cd ~/dev/robot-tests
source .venv/bin/activate

# расширенный HTTP набор
robot -d reports tests/sber_http.robot

# расширенный UI набор
robot -d reports tests/sber_ui.robot

# только быстрые smoke
robot -d reports api_smoke.robot sber_smoke.robot

# все Sber тесты разом
robot -d reports tests/sber_http.robot tests/sber_ui.robot api_smoke.robot sber_smoke.robot
```

## Примечание по стабильности

Сайт может отдавать anti-bot/блок-страницу в части окружений. В расширенных тестах это учтено:

- при недоступности основного домена используется fallback;
- часть проверок выполняется в мягком режиме с предупреждением в отчете, чтобы избежать ложных падений.
