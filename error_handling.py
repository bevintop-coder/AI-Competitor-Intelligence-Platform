import requests
from bs4 import BeautifulSoup

url = "https://example.com"

try:
    result = requests.get(url, timeout=10)
    result.raise_for_status()

    page = BeautifulSoup(result.content, "html.parser")

    if page.title:
        print("Website Title:", page.title.get_text(strip=True))
    else:
        print("Title not available")

except requests.RequestException as error:
    print("Failed to load website:", error)
