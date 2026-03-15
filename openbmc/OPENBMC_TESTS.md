# OpenBMC test suite (Robot Framework)

Набор разделен по уровням:

- `openbmc/tests/openbmc_redfish_smoke.robot` — базовая доступность Redfish и ключевых коллекций.
- `openbmc/tests/openbmc_redfish_regression.robot` — расширенные проверки сети, сенсоров, логов, сервисов.
- `openbmc/tests/openbmc_redfish_destructive.robot` — destructive-проверки reset действий (ручной запуск).

## Детальные описания тестов

### Smoke

- `Service Root Is Available` — проверяет доступность `/redfish/v1` и наличие обязательных ссылок `Systems`, `Managers`, `Chassis`.
- `Systems Collection Is Available` — проверяет коллекцию систем и базовые поля каждой выбранной системы.
- `Managers Collection Is Available` — проверяет коллекцию менеджеров и поля `Id`, `Name`, `ManagerType`.
- `Chassis Collection Is Available` — проверяет коллекцию шасси и валидирует базовые атрибуты.
- `Core Services Are Reachable` — проверяет доступность `SessionService`, `AccountService`, `UpdateService`.

### Regression

- `Validate Managers Ethernet Interfaces` — проверяет сетевые интерфейсы менеджера и допустимые состояния линка.
- `Validate Chassis Thermal And Power` — проверяет наличие и доступность `Thermal` и `Power` endpoint'ов.
- `Validate Log Services And Entries` — проверяет `LogServices` и коллекции `Entries`.
- `Validate Event And Task Services` — проверяет доступность `EventService` и `TaskService`.
- `Validate Telemetry Service If Present` — проверяет `TelemetryService` (допускает 401/403 при ограничениях).

### Destructive

- `System Reset Action Is Advertised` — проверяет объявление `#ComputerSystem.Reset`.
- `BMC Reset Action Is Advertised` — проверяет объявление `#Manager.Reset`.
- `Execute BMC Graceful Restart` — выполняет `Manager.Reset` с `GracefulRestart` (только при `OPENBMC_ALLOW_DESTRUCTIVE=true`).

## Конфигурация

Используются переменные окружения (файл `openbmc/config/openbmc_config.py`):

- `OPENBMC_HOST` (например, `192.168.1.100`)
- `OPENBMC_SCHEME` (`https` или `http`)
- `OPENBMC_USERNAME`
- `OPENBMC_PASSWORD`
- `OPENBMC_VERIFY_TLS` (`true`/`false`)
- `OPENBMC_ALLOW_DESTRUCTIVE` (`true`/`false`)

## Запуск

```bash
cd ~/dev/robot-tests
source .venv/bin/activate

# smoke
robot -d reports -i smoke openbmc/tests/openbmc_redfish_smoke.robot

# regression
robot -d reports -i regression openbmc/tests/openbmc_redfish_regression.robot

# destructive (только если действительно нужно)
OPENBMC_ALLOW_DESTRUCTIVE=true robot -d reports -i destructive openbmc/tests/openbmc_redfish_destructive.robot
```
