import os


BMC_SCHEME = os.getenv("OPENBMC_SCHEME", "https")
BMC_HOST = os.getenv("OPENBMC_HOST", "192.168.1.100")
BMC_BASE_URL = f"{BMC_SCHEME}://{BMC_HOST}"

BMC_USERNAME = os.getenv("OPENBMC_USERNAME", "root")
BMC_PASSWORD = os.getenv("OPENBMC_PASSWORD", "0penBmc")
BMC_AUTH = (BMC_USERNAME, BMC_PASSWORD)

VERIFY_TLS = os.getenv("OPENBMC_VERIFY_TLS", "false").lower() == "true"
REQUEST_TIMEOUT_SECONDS = int(os.getenv("OPENBMC_TIMEOUT_SECONDS", "20"))

ALLOW_DESTRUCTIVE = os.getenv("OPENBMC_ALLOW_DESTRUCTIVE", "false").lower() == "true"
WAIT_AFTER_RESET_SECONDS = int(os.getenv("OPENBMC_WAIT_AFTER_RESET_SECONDS", "15"))

MIN_COLLECTION_SIZE = int(os.getenv("OPENBMC_MIN_COLLECTION_SIZE", "1"))
MAX_MEMBERS_TO_VALIDATE = int(os.getenv("OPENBMC_MAX_MEMBERS_TO_VALIDATE", "10"))

ALLOWED_HEALTH_STATES = ["OK", "Warning"]
ALLOWED_POWER_STATES = ["On", "Off", "PoweringOn", "PoweringOff"]
ALLOWED_LINK_STATES = ["Up", "Down", "Unknown"]

SERVICE_ROOT = "/redfish/v1"
SYSTEMS = "/redfish/v1/Systems"
MANAGERS = "/redfish/v1/Managers"
CHASSIS = "/redfish/v1/Chassis"
SESSION_SERVICE = "/redfish/v1/SessionService"
ACCOUNT_SERVICE = "/redfish/v1/AccountService"
UPDATE_SERVICE = "/redfish/v1/UpdateService"
TASK_SERVICE = "/redfish/v1/TaskService"
EVENT_SERVICE = "/redfish/v1/EventService"
TELEMETRY_SERVICE = "/redfish/v1/TelemetryService"
