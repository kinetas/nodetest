import requests
from bs4 import BeautifulSoup
import json
import uuid
import time

# User-Agent 강화 (최신 크롬 헤더처럼)
HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/123.0.0.0 Safari/537.36"
    )
}

# 블로그 링크 추출 함수
def get_blog_links(keyword, max_links=3):
    query = keyword.replace(" ", "+")
    url = f"https://search.naver.com/search.naver?where=view&query={query}&sm=tab_opt"
    res = requests.get(url, headers=HEADERS)
    print(f"🔍 [{keyword}] 검색 페이지 응답코드: {res.status_code}")

    soup = BeautifulSoup(res.text, "html.parser")

    links = []
    for a in soup.select("a.api_txt_lines.total_tit"):
        href = a.get("href")
        if href.startswith("https://blog.naver.com"):
            print("✅ 블로그 링크 발견:", href)
            links.append(href)
        if len(links) >= max_links:
            break

    print(f"🔗 수집된 블로그 링크 수: {len(links)}")
    return links

# 블로그 본문 추출 함수
def crawl_naver_blog(url):
    try:
        res = requests.get(url, headers=HEADERS)
        soup = BeautifulSoup(res.text, "html.parser")

        iframe = soup.select_one("iframe#mainFrame")
        if not iframe:
            print("❗ iframe 없음:", url)
            return ""

        iframe_url = "https://blog.naver.com" + iframe["src"]
        res2 = requests.get(iframe_url, headers=HEADERS)
        soup2 = BeautifulSoup(res2.text, "html.parser")

        content_div = (
            soup2.select_one("div.se-main-container") or
            soup2.select_one("div#postViewArea")
        )
        if content_div:
            return content_div.get_text("\n", strip=True)

        print("❗ 본문 div 없음:", iframe_url)
        return ""

    except Exception as e:
        print("❌ 예외 발생:", e)
        return ""

# 수집 키워드
keywords = [
    ("미라클 모닝 루틴", "자기관리"),
    ("자기개발 루틴", "자기개발"),
    ("운동 루틴", "운동"),
    ("요리 루틴", "생활습관")
]

collected = []

for keyword, category in keywords:
    print(f"\n🔍 '{keyword}' 키워드로 블로그 검색 시작...")
    blog_links = get_blog_links(keyword)

    for link in blog_links:
        print("➡ 블로그 본문 추출 시도:", link)
        content = crawl_naver_blog(link)
        print("📄 본문 길이:", len(content))
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

# 저장
with open("blog_data.json", "w", encoding="utf-8") as f:
    json.dump(collected, f, ensure_ascii=False, indent=2)

print(f"\n✅ {len(collected)}개의 블로그 문서 저장 완료 → blog_data.json")
