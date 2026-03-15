import os


def _get_int(name: str, default: int) -> int:
    raw = os.getenv(name, "").strip()
    if not raw:
        return default
    try:
        return int(raw)
    except ValueError:
        return default


def _get_bool(name: str, default: bool) -> bool:
    raw = os.getenv(name, "").strip().lower()
    if not raw:
        return default
    return raw in {"1", "true", "yes", "on"}


def _get_csv(name: str, default: str) -> list[str]:
    raw = os.getenv(name, default)
    return [item.strip() for item in raw.split(",") if item.strip()]


SCT_COMMAND = os.getenv("UEFI_SCT_COMMAND", "").strip()
SCT_WORKDIR = os.getenv("UEFI_SCT_WORKDIR", ".").strip()

SCT_RESULTS_DIR = os.getenv("UEFI_SCT_RESULTS_DIR", "uefi-sct-wrapper/results").strip()
SCT_STDOUT_FILE = os.getenv(
    "UEFI_SCT_STDOUT_FILE",
    f"{SCT_RESULTS_DIR}/sct_stdout.log",
).strip()
SCT_STDERR_FILE = os.getenv(
    "UEFI_SCT_STDERR_FILE",
    f"{SCT_RESULTS_DIR}/sct_stderr.log",
).strip()

SCT_COMMAND_TIMEOUT_SECONDS = _get_int("UEFI_SCT_TIMEOUT_SECONDS", 5400)
SCT_EXPECTED_EXIT_CODES = _get_csv("UEFI_SCT_EXPECTED_EXIT_CODES", "0")
SCT_SUMMARY_REGEX = os.getenv(
    "UEFI_SCT_SUMMARY_REGEX",
    r"(?i)(failed\s*[:=]\s*0|pass(ed)?\s*[:=]\s*\d+)",
).strip()
SCT_REQUIRED_ARTIFACTS = _get_csv("UEFI_SCT_REQUIRED_ARTIFACTS", "")
SCT_REQUIRE_NONEMPTY_LOG = _get_bool("UEFI_SCT_REQUIRE_NONEMPTY_LOG", True)
