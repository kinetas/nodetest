import requests
from bs4 import BeautifulSoup
import json
import uuid
import time

# 네이버 블로그 검색 결과에서 글 링크 추출하는 함수
def get_blog_links(keyword, max_links=3): #여기서 max값으로 개수 바꿈꿈
    headers = {"User-Agent": "Mozilla/5.0"}
    query = keyword.replace(" ", "+")
    search_url = f"https://search.naver.com/search.naver?where=view&query={query}&sm=tab_opt"
    res = requests.get(search_url, headers=headers)
    soup = BeautifulSoup(res.text, "html.parser")

    links = []
    for a in soup.select("a.api_txt_lines.total_tit"):
        href = a.get("href")
        if href.startswith("https://blog.naver.com"):
            links.append(href)
        if len(links) >= max_links:
            break
    return links

# 블로그 본문 크롤링 (iframe 안쪽까지)
def crawl_naver_blog(url):
    headers = {"User-Agent": "Mozilla/5.0"}
    res = requests.get(url, headers=headers)
    soup = BeautifulSoup(res.text, "html.parser")

    iframe = soup.select_one("iframe#mainFrame")
    if not iframe:
        return ""
    iframe_url = "https://blog.naver.com" + iframe["src"]
    res2 = requests.get(iframe_url, headers=headers)

    if res2.status_code != 200:
        return ""

    soup2 = BeautifulSoup(res2.text, "html.parser")

    # ✅ 새 에디터용
    content_div = soup2.select_one("div.se-main-container")

    # ✅ 구버전 블로그용
    if not content_div:
        content_div = soup2.select_one("div#postViewArea")

    if content_div:
        return content_div.get_text("\n", strip=True)

    return ""

# 여러 키워드로 수집
keywords = [
    ("미라클 모닝 루틴", "자기관리"),
    ("자기개발 루틴", "자기개발"),
    ("운동 루틴", "운동"),
    ("요리 루틴", "생활습관")
]

collected = []

for keyword, category in keywords:
    blog_links = get_blog_links(keyword)
    for link in blog_links:
        content = crawl_naver_blog(link)
        time.sleep(3)
        if content:
            collected.append({
                "id": str(uuid.uuid4()),
                "document": content[:2000],
                "metadata": {
                    "tag": keyword,
                    "category": category,
                    "source": link
                }
            })

# json 저장장
with open("blog_data.json", "w", encoding="utf-8") as f:
    json.dump(collected, f, ensure_ascii=False, indent=2)

print(f"{len(collected)}개의 블로그 문서 저장 완료 → blog_data.json")