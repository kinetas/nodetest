# import requests
# from bs4 import BeautifulSoup
# import json
# import uuid
# import time

# # User-Agent 강화 (최신 크롬 헤더처럼)
# HEADERS = {
#     "User-Agent": (
#         "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
#         "AppleWebKit/537.36 (KHTML, like Gecko) "
#         "Chrome/123.0.0.0 Safari/537.36"
#     )
# }

# # 블로그 링크 추출 함수
# def get_blog_links(keyword, max_links=3):
#     query = keyword.replace(" ", "+")
#     url = f"https://search.naver.com/search.naver?where=view&query={query}&sm=tab_opt"
#     res = requests.get(url, headers=HEADERS)
#     print(f"🔍 [{keyword}] 검색 페이지 응답코드: {res.status_code}")

#     soup = BeautifulSoup(res.text, "html.parser")

#     links = []
#     for a in soup.select("a.api_txt_lines.total_tit"):
#         href = a.get("href")
#         if href.startswith("https://blog.naver.com"):
#             print("✅ 블로그 링크 발견:", href)
#             links.append(href)
#         if len(links) >= max_links:
#             break

#     print(f"🔗 수집된 블로그 링크 수: {len(links)}")
#     return links

# # 블로그 본문 추출 함수
# def crawl_naver_blog(url):
#     try:
#         res = requests.get(url, headers=HEADERS)
#         soup = BeautifulSoup(res.text, "html.parser")

#         iframe = soup.select_one("iframe#mainFrame")
#         if not iframe:
#             print("❗ iframe 없음:", url)
#             return ""

#         iframe_url = "https://blog.naver.com" + iframe["src"]
#         res2 = requests.get(iframe_url, headers=HEADERS)
#         soup2 = BeautifulSoup(res2.text, "html.parser")

#         content_div = (
#             soup2.select_one("div.se-main-container") or
#             soup2.select_one("div#postViewArea")
#         )
#         if content_div:
#             return content_div.get_text("\n", strip=True)

#         print("❗ 본문 div 없음:", iframe_url)
#         return ""

#     except Exception as e:
#         print("❌ 예외 발생:", e)
#         return ""

# # 수집 키워드
# keywords = [
#     ("미라클 모닝 루틴", "자기관리"),
#     ("자기개발 루틴", "자기개발"),
#     ("운동 루틴", "운동"),
#     ("요리 루틴", "생활습관")
# ]

# collected = []

# for keyword, category in keywords:
#     print(f"\n🔍 '{keyword}' 키워드로 블로그 검색 시작...")
#     blog_links = get_blog_links(keyword)

#     for link in blog_links:
#         print("➡ 블로그 본문 추출 시도:", link)
#         content = crawl_naver_blog(link)
#         print("📄 본문 길이:", len(content))
#         time.sleep(3)

#         if content:
#             collected.append({
#                 "id": str(uuid.uuid4()),
#                 "document": content[:2000],
#                 "metadata": {
#                     "tag": keyword,
#                     "category": category,
#                     "source": link
#                 }
#             })

# # 저장
# with open("blog_data.json", "w", encoding="utf-8") as f:
#     json.dump(collected, f, ensure_ascii=False, indent=2)

# print(f"\n✅ {len(collected)}개의 블로그 문서 저장 완료 → blog_data.json")


# from selenium import webdriver
# from selenium.webdriver.chrome.options import Options
# from selenium.webdriver.common.by import By
# from selenium.webdriver.support.ui import WebDriverWait
# from selenium.webdriver.support import expected_conditions as EC
# from selenium.webdriver.chrome.service import Service
# from webdriver_manager.chrome import ChromeDriverManager
# import time
# import json
# import uuid

# # 검색 키워드
# keywords = [
#     ("미라클 모닝 루틴", "자기관리"),
#     ("자기개발 루틴", "자기개발"),
#     ("운동 루틴", "운동"),
#     ("요리 루틴", "생활습관")
# ]

# # 크롬 옵션 설정
# options = Options()
# options.add_argument("--headless")
# options.add_argument("--no-sandbox")
# options.add_argument("--disable-dev-shm-usage")

# driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

# collected = []

# for keyword, category in keywords:
#     print(f"\n🔍 '{keyword}' 키워드로 블로그 검색 시작...")
#     search_url = f"https://search.naver.com/search.naver?where=blog&query={keyword}&sm=tab_opt"

#     driver.get(search_url)

#     try:
#         WebDriverWait(driver, 5).until(
#             EC.presence_of_all_elements_located((By.CSS_SELECTOR, "a.api_txt_lines.total_tit"))
#         )
#         link_elements = driver.find_elements(By.CSS_SELECTOR, "a.api_txt_lines.total_tit")
#         links = [a.get_attribute("href") for a in link_elements if "blog.naver.com" in a.get_attribute("href")][:3]

#         print(f"🔗 수집된 블로그 링크 수: {len(links)}")

#         for link in links:
#             driver.get(link)
#             time.sleep(3)  # iframe 로딩 대기

#             try:
#                 driver.switch_to.frame("mainFrame")
#                 content_elem = driver.find_element(By.CSS_SELECTOR, "div.se-main-container")
#                 content = content_elem.text.strip()
#             except:
#                 content = ""

#             if content:
#                 collected.append({
#                     "id": str(uuid.uuid4()),
#                     "document": content[:2000],
#                     "metadata": {
#                         "tag": keyword,
#                         "category": category,
#                         "source": link
#                     }
#                 })

#     except Exception as e:
#         print(f"⚠ 블로그 링크 수집 실패: {e.__class__.__name__}: {e}")
#     time.sleep(2)

# driver.quit()

# with open("blog_data.json", "w", encoding="utf-8") as f:
#     json.dump(collected, f, ensure_ascii=False, indent=2)

# print(f"\n✅ {len(collected)}개의 블로그 문서 저장 완료 → blog_data.json")

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup
import time, json, uuid

# 셀레니움 옵션 설정
options = Options()
options.add_argument('--headless')  # GUI 없이 실행
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')
options.add_argument('--disable-gpu')
options.add_argument('--window-size=1920x1080')

driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

keywords = ["미라클 모닝 루틴", "자기개발 루틴", "운동 루틴", "요리 루틴"]
collected = []

for keyword in keywords:
    print(f"🔍 '{keyword}' 블로그 검색 시작...")
    search_url = f"https://section.blog.naver.com/Search/Post.naver?keyword={keyword}"
    driver.get(search_url)
    time.sleep(3)  # 페이지 로딩 대기

    soup = BeautifulSoup(driver.page_source, "html.parser")
    cards = soup.select("div.desc > a")

    links = []
    for a in cards:
        href = a.get("href")
        if href and "blog.naver.com" in href:
            links.append(href)

    print(f"🔗 수집된 블로그 링크 수: {len(links)}")

    for link in links:
        driver.get(link)
        time.sleep(2)
        blog_soup = BeautifulSoup(driver.page_source, "html.parser")
        content = blog_soup.get_text(separator="\n").strip()
        if content:
            collected.append({
                "id": str(uuid.uuid4()),
                "document": content[:2000],
                "metadata": {
                    "tag": keyword,
                    "category": "루틴",
                    "source": link
                }
            })

driver.quit()

with open("blog_data.json", "w", encoding="utf-8") as f:
    json.dump(collected, f, ensure_ascii=False, indent=2)

print(f"✅ {len(collected)}개의 블로그 문서 저장 완료 → blog_data.json")
