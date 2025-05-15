import time
import uuid
import json
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

# ✅ 블로그 본문 내용 추출 함수
def extract_blog_content(driver, url):
    try:
        driver.get(url)
        time.sleep(2)

        driver.switch_to.frame("mainFrame")
        time.sleep(1)

        try:
            content = driver.find_element(By.CSS_SELECTOR, "div.se-main-container").text.strip()
        except:
            content = driver.find_element(By.CSS_SELECTOR, "div#postViewArea").text.strip()

        driver.switch_to.default_content()
        return content
    except Exception as e:
        print(f"❌ 본문 추출 실패: {e}")
        return ""

# ✅ 검색 키워드 목록
keywords = [
    ("미라클 모닝 루틴", "루틴"),
    ("자기개발 루틴", "루틴"),
    ("운동 루틴", "루틴"),
    ("요리 루틴", "루틴")
]

# ✅ 셀레니움 설정
options = Options()
options.add_argument('--headless')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')
options.add_argument('--disable-gpu')
options.add_argument('--window-size=1920x1080')

# ✅ 드라이버 실행
print("🔄 크롬 드라이버 실행 중...")
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()), options=options)

collected = []

for keyword, category in keywords:
    print(f"\n🔍 '{keyword}' 블로그 검색 시작...")
    search_url = f"https://section.blog.naver.com/Search/Post.naver?keyword={keyword}"
    driver.get(search_url)

    try:
        WebDriverWait(driver, 15).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, "div.desc > a"))
        )
        cards = driver.find_elements(By.CSS_SELECTOR, "div.desc > a")
        links = [card.get_attribute("href") for card in cards[:3]]
        print(f"🔗 수집된 블로그 링크 수: {len(links)}")

        for link in links:
            content = extract_blog_content(driver, link)
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
            time.sleep(3)  # 딜레이 추가

    except Exception as e:
        print(f"⚠ 블로그 링크 수집 실패: {e}")

# ✅ 종료 및 저장
driver.quit()

with open("blog_data.json", "w", encoding="utf-8") as f:
    json.dump(collected, f, ensure_ascii=False, indent=2)

print(f"\n✅ {len(collected)}개의 블로그 문서 저장 완료 → blog_data.json")