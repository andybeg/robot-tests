# UEFI SCT wrapper (Robot Framework)

Отдельный подпроект-обертка для запуска внешнего `System Configuration Test (SCT)` и проверки результата через Robot Framework.

## Что делает обертка

- запускает команду `UEFI_SCT_COMMAND` (любой ваш launcher: QEMU, стенд, IPMI/serial harness и т.д.);
- сохраняет stdout/stderr в лог-файлы;
- валидирует код завершения;
- ищет summary в логах по regex;
- опционально проверяет наличие артефактов.

## Как это работает с OpenBMC

Обертка сама не вызывает API OpenBMC напрямую. Она запускает только одну внешнюю команду:

- `bash -lc "${UEFI_SCT_COMMAND}"`.

Поэтому вся логика работы с BMC находится в вашей команде/скрипте, который передан в `UEFI_SCT_COMMAND`:

- подключение к OpenBMC (Redfish/IPMI/SSH);
- подготовка загрузки (boot override, virtual media и т.п.);
- перезагрузка хоста и ожидание завершения SCT;
- сбор логов и артефактов;
- возврат корректного `exit code`.

После завершения команды Robot-обертка делает только валидацию результата:

- проверяет `exit code`;
- проверяет summary в stdout/stderr по `UEFI_SCT_SUMMARY_REGEX`;
- проверяет наличие обязательных файлов из `UEFI_SCT_REQUIRED_ARTIFACTS`.

## Откуда запускать при наличии OpenBMC-сервера

Запускать нужно с отдельной машины-оркестратора (не с самого BMC):

- CI runner;
- jump host в лаборатории;
- локальная инженерная машина.

Главное требование: эта машина должна иметь сетевой доступ к OpenBMC и к месту, где формируются логи/артефакты SCT.

## Структура

- `config/uefi_sct_config.py` — переменные и параметры из env;
- `resources/uefi_sct_keywords.robot` — ключевые слова обертки;
- `tests/uefi_system_configuration_wrapper.robot` — основной smoke suite.

## Настройка

Минимально обязательный параметр:

- `UEFI_SCT_COMMAND` — команда запуска SCT.

Дополнительные параметры:

- `UEFI_SCT_WORKDIR` (default: `.`)
- `UEFI_SCT_TIMEOUT_SECONDS` (default: `5400`)
- `UEFI_SCT_EXPECTED_EXIT_CODES` (default: `0`, CSV)
- `UEFI_SCT_SUMMARY_REGEX` (default: `(?i)(failed\\s*[:=]\\s*0|pass(ed)?\\s*[:=]\\s*\\d+)`)
- `UEFI_SCT_RESULTS_DIR` (default: `uefi-sct-wrapper/results`)
- `UEFI_SCT_STDOUT_FILE` (default: `${UEFI_SCT_RESULTS_DIR}/sct_stdout.log`)
- `UEFI_SCT_STDERR_FILE` (default: `${UEFI_SCT_RESULTS_DIR}/sct_stderr.log`)
- `UEFI_SCT_REQUIRED_ARTIFACTS` (default: empty, CSV paths)
- `UEFI_SCT_REQUIRE_NONEMPTY_LOG` (default: `true`)

## Пример запуска

```bash
cd ~/dev/robot-tests
source .venv/bin/activate

export UEFI_SCT_COMMAND='python3 -c "print(\"SCT: Passed=42 Failed=0\")"'
export UEFI_SCT_EXPECTED_EXIT_CODES='0'
export UEFI_SCT_SUMMARY_REGEX='(?i)failed\\s*[:=]\\s*0'

robot -d reports uefi-sct-wrapper/tests/uefi_system_configuration_wrapper.robot
```

## Пример с артефактами

```bash
export UEFI_SCT_REQUIRED_ARTIFACTS='uefi-sct-wrapper/results/sct_stdout.log,uefi-sct-wrapper/results/sct_stderr.log'
robot -d reports uefi-sct-wrapper/tests/uefi_system_configuration_wrapper.robot
```

## Пример для OpenBMC launcher

Рекомендуемый подход: вынести интеграцию с OpenBMC в отдельный скрипт, а в обертку передавать только его:

```bash
export UEFI_SCT_COMMAND='./scripts/run_sct_via_openbmc.sh'
robot -d reports uefi-sct-wrapper/tests/uefi_system_configuration_wrapper.robot
```

Где `run_sct_via_openbmc.sh` уже реализует нужный сценарий (Redfish/ipmitool/ssh), а также пишет итоговые логи в `uefi-sct-wrapper/results/`.

## Интеграция в CI

1. Передайте `UEFI_SCT_COMMAND` и остальные env в job.
2. Запускайте только suite обертки:
   `robot -d reports uefi-sct-wrapper/tests/uefi_system_configuration_wrapper.robot`
3. Публикуйте `reports/` и `uefi-sct-wrapper/results/` как артефакты.
