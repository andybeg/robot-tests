BASE_URL = "https://www.sber.ru"
ALLOWED_URL_REGEXP = r"https?://(www\.)?(sber\.ru|sberbank\.com)(/.*)?"
BROWSER = "chrome"
BROWSER_OPTIONS = (
    'add_argument("--headless=new");'
    'add_argument("--window-size=1920,1080");'
    'add_argument("--disable-gpu")'
)
SELENIUM_TIMEOUT = "15s"
MIN_ANCHORS_COUNT = 10
MIN_BUTTONS_COUNT = 1
MIN_FORM_CONTROLS_COUNT = 1
