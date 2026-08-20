import requests
from bs4 import BeautifulSoup

website = "https://example.com"

html = requests.get(website).content
soup = BeautifulSoup(html, "html.parser")

title_tag = soup.select_one("title")

if title_tag:
    print("Title:", title_tag.get_text(strip=True))
else:
    print("No title found")
