import os
import requests
import json
import uuid
from dotenv import load_dotenv

# ✅ .env 파일 로드
load_dotenv()

# ✅ 환경변수에서 API 정보 로드
NAVER_CLIENT_ID = os.getenv("NAVER_CLIENT_ID")
NAVER_CLIENT_SECRET = os.getenv("NAVER_CLIENT_SECRET")

# ✅ 블로그 검색 함수
def search_naver_blog(query, display=10):
    url = "https://openapi.naver.com/v1/search/blog.json"
    headers = {
        "X-Naver-Client-Id": NAVER_CLIENT_ID,
        "X-Naver-Client-Secret": NAVER_CLIENT_SECRET,
    }
    params = {
        "query": query,
        "display": display,
        "sort": "sim"  # 관련도 순
    }
    response = requests.get(url, headers=headers, params=params)
    if response.status_code == 200:
        return response.json()["items"]
    else:
        print("❌ API 호출 실패:", response.text)
        return []

# ✅ 수집할 키워드와 카테고리
keywords = [
    ("미라클 모닝 루틴", "자기관리"),
    ("자기개발 종류", "자기개발"),
    ("운동 종류", "자기개발"),
    ("요리 종류", "생활습관"),
    ("피부관리", "자기관리"),
    ("독서 습관", "자기개발"),
    ("다이어트 식단", "건강관리"),
    ("집 정리 정돈", "생활습관"),
    ("집중력 향상 방법", "생활습관"),
    ("힐링", "자기관리"),
    ("보드 게임", "자기관리"),
    ("졸음 해소", "자기관리"),
    ("돈 절약", "생활습관"),
    ("협업", "사회생활"),
    ("30분 활동", "자기개발"),
    ("10분 활동", "자기개발"),
    ("5분활동", "자기개발")
]

# ✅ RAG용 문서 형태로 변환
documents = []

for keyword, category in keywords:
    print(f"🔍 '{keyword}' 블로그 검색 중...")
    items = search_naver_blog(keyword, display=10)
    for item in items:
        documents.append({
            "id": str(uuid.uuid4()),
            "document": item["description"].replace("<b>", "").replace("</b>", ""),
            "metadata": {
                "tag": keyword,
                "category": category,
                "title": item["title"].replace("<b>", "").replace("</b>", ""),
                "source": item["link"]
            }
        })

# ✅ 저장
output = {"documents": documents}
with open("naver_blog_data.json", "w", encoding="utf-8") as f:
    json.dump(output, f, ensure_ascii=False, indent=2)

print(f"✅ {len(documents)}개의 문서를 naver_blog_data.json에 저장 완료")