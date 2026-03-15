PRIMARY_URL = "https://www.sber.ru"
FALLBACK_URL = "https://www.sberbank.com"
ALLOWED_URL_REGEXP = r"https?://(www\.)?(sber\.ru|sberbank\.com)(/.*)?"
ALLOWED_STATUS_CODES = [200, 301, 302, 307, 308, 403]
HOMEPAGE_PATH = "/"
ROBOTS_PATH = "/robots.txt"
SITEMAP_PATH = "/sitemap.xml"
REQUEST_TIMEOUT_SECONDS = 20
MAX_HOME_RESPONSE_SECONDS = 5.0
MAX_LINKS_TO_CHECK = 15
MIN_INTERNAL_LINKS = 5
ALLOWED_DOMAINS = ["sber.ru", "sberbank.com"]
SECURITY_HEADERS_REQUIRED = ["Strict-Transport-Security"]
SECURITY_HEADERS_RECOMMENDED = [
    "Content-Security-Policy",
    "X-Frame-Options",
    "X-Content-Type-Options",
    "Referrer-Policy",
]
