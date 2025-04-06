import requests
import json
import uuid
import time
import os
from dotenv import load_dotenv

# 🔐 환경변수 로딩
load_dotenv()
NAVER_CLIENT_ID = os.getenv("NAVER_CLIENT_ID")
NAVER_CLIENT_SECRET = os.getenv("NAVER_CLIENT_SECRET")

headers = {
    "X-Naver-Client-Id": NAVER_CLIENT_ID,
    "X-Naver-Client-Secret": NAVER_CLIENT_SECRET
}

# 🔍 키워드 + 카테고리 리스트
keywords = [
    ("미라클 모닝 루틴", "자기관리"),
    ("자기개발 루틴", "자기개발"),
    ("운동 루틴", "자기개발"),
    ("요리 루틴", "생활습관"),
    ("피부관리", "자기관리"),
    ("독서 습관", "자기개발"),
    ("다이어트 식단", "건강관리"),
    ("집 정리 정돈", "생활습관"),
    ("집중력 향상 루틴", "생활습관"),
    ("힐링", "자기관리")
]

collected = []

for keyword, category in keywords:
    print(f"🔍 '{keyword}' 블로그 검색 중...")

    url = f"https://openapi.naver.com/v1/search/blog.json?query={keyword}&display=5"
    res = requests.get(url, headers=headers)

    if res.status_code == 200:
        items = res.json().get("items", [])
        for item in items:
            collected.append({
                "id": str(uuid.uuid4()),
                "document": item["title"],
                "metadata": {
                    "tag": keyword,
                    "category": category,
                    "source": item["link"]
                }
            })
        print(f"✅ 수집된 항목 수: {len(items)}")
    else:
        print(f"⚠ 실패: {res.status_code} - {res.text}")

    time.sleep(1.5)  # 💡 API 과부하 방지

# 💾 저장
with open("blog_data_naver.json", "w", encoding="utf-8") as f:
    json.dump(collected, f, ensure_ascii=False, indent=2)

print(f"\n📦 총 {len(collected)}개 문서 저장 완료 → blog_data_naver.json")
