import requests
from bs4 import BeautifulSoup

def get_page_title(url):
    page = requests.get(url)
    page.raise_for_status()

    document = BeautifulSoup(page.content, "html.parser")
    return document.find("title").get_text(strip=True)

website = "https://example.com"

title = get_page_title(website)
print("Page Title:", title)
