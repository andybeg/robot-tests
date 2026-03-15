from html.parser import HTMLParser
from urllib.parse import urljoin, urlparse


class _HrefParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.hrefs = []

    def handle_starttag(self, tag, attrs):
        if tag.lower() != "a":
            return
        for key, value in attrs:
            if key.lower() == "href" and value:
                self.hrefs.append(value.strip())
                break


def extract_internal_links(html, base_url, allowed_domains, max_links=15):
    parser = _HrefParser()
    parser.feed(html or "")

    normalized_domains = [d.lower().strip() for d in allowed_domains or []]
    links = []
    seen = set()

    for href in parser.hrefs:
        if href.startswith(("#", "mailto:", "tel:", "javascript:")):
            continue

        absolute = urljoin(base_url, href)
        parsed = urlparse(absolute)
        if parsed.scheme not in ("http", "https"):
            continue

        host = (parsed.netloc or "").lower()
        if not any(host == d or host.endswith("." + d) for d in normalized_domains):
            continue

        cleaned = f"{parsed.scheme}://{parsed.netloc}{parsed.path or '/'}"
        if parsed.query:
            cleaned = f"{cleaned}?{parsed.query}"

        if cleaned in seen:
            continue

        seen.add(cleaned)
        links.append(cleaned)
        if len(links) >= int(max_links):
            break

    return links


def get_header(headers, header_name):
    if headers is None:
        return ""
    for key, value in headers.items():
        if str(key).lower() == str(header_name).lower():
            return str(value)
    return ""


def get_missing_headers(headers, header_names):
    missing = []
    for name in header_names or []:
        if not get_header(headers, name):
            missing.append(name)
    return missing
