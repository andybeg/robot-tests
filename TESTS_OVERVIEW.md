# Обзор тестов robot-tests

## Sber тесты

- `tests/sber_http.robot` — расширенные HTTP-проверки: доступность, SEO endpoints, security headers, внутренние ссылки, время ответа.
- `tests/sber_ui.robot` — UI-проверки в Selenium headless: загрузка страницы, валидация URL/title, наличие базовых контролов.
- `sber_smoke.robot` — legacy UI smoke для ручного быстрого запуска.
- `api_smoke.robot` — legacy HTTP smoke для ручного быстрого запуска.
- Детальное описание сценариев и конфигов: `SBER_TESTS.md`.

## OpenBMC тесты

- `openbmc/tests/openbmc_redfish_smoke.robot` — базовые Redfish проверки.
- `openbmc/tests/openbmc_redfish_regression.robot` — расширенные проверки подсистем OpenBMC.
- `openbmc/tests/openbmc_redfish_destructive.robot` — destructive сценарии reset.

Подробное описание OpenBMC сценариев см. в `openbmc/OPENBMC_TESTS.md`.

## UEFI SCT wrapper

- `uefi-sct-wrapper/tests/uefi_system_configuration_wrapper.robot` — обертка запуска внешнего UEFI System Configuration Test.
- `uefi-sct-wrapper/resources/uefi_sct_keywords.robot` — keywords для запуска команды SCT, проверки exit code, summary и артефактов.
- `uefi-sct-wrapper/config/uefi_sct_config.py` — конфигурация через env-переменные.

Описание и примеры запуска: `uefi-sct-wrapper/README.md`.
