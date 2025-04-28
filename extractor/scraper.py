import requests
from bs4 import BeautifulSoup

def scrape_liturgia():
    url = 'https://liturgia.cancaonova.com/pb/'
    response = requests.get(url, timeout=10)
    response.raise_for_status()
    soup = BeautifulSoup(response.content, 'html.parser')
    liturgia_1 = soup.find(id="liturgia-1").get_text(strip=True) if soup.find(id="liturgia-1") else ""
    liturgia_2 = soup.find(id="liturgia-2").get_text(strip=True) if soup.find(id="liturgia-2") else ""
    liturgia_3 = soup.find(id="liturgia-3").get_text(strip=True) if soup.find(id="liturgia-3") else ""
    liturgia_4 = soup.find(id="liturgia-4").get_text(strip=True) if soup.find(id="liturgia-4") else ""
    liturgia_completa = f"{liturgia_1}\n\n{liturgia_2}\n\n{liturgia_3}\n\n{liturgia_4}"
    return liturgia_completa
