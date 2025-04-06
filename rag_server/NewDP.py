import json
import requests
from langchain_community.vectorstores import Chroma
from langchain.schema import Document
from langchain_ollama import OllamaEmbeddings
import hashlib
from langchain.text_splitter import CharacterTextSplitter
from langchain_chroma import Chroma
from dotenv import load_dotenv
import os

# ✅ 환경 변수 로드
load_dotenv()

# ✅ 요약용 Groq API 설정
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"

# ✅ JSON 파일 경로
json_file = "naver_blog_data.json"

# ✅ Chroma 설정
persist_directory = "/chroma/chroma"
embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="llama3")
db = Chroma(persist_directory=persist_directory, embedding_function=embedding)

# ✅ 기존 문서 삭제 (초기화)
existing = db.get()
ids = existing["ids"]
if ids:
    db.delete(ids=ids)
    print(f"🧹 기존 문서 {len(ids)}개 삭제 완료")

# ✅ 요약 함수 (Groq 호출)
def summarize(text):
    prompt = f"다음 글을 간결하게 요약해줘. 한국어로 2~3문장 정도로.\n\n{text[:2000]}"

    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json"
    }
    body = {
        "model": "llama3-8b-8192",
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.3
    }

    try:
        res = requests.post(GROQ_API_URL, headers=headers, json=body)
        res.raise_for_status()
        result = res.json()
        return result["choices"][0]["message"]["content"].strip()
    except Exception as e:
        print("⚠️ 요약 실패:", e)
        return text[:300]  # 요약 실패 시 앞부분 사용

# ✅ JSON 불러오기
with open(json_file, "r", encoding="utf-8") as f:
    data = json.load(f)

# ✅ 문서 가공 및 요약 삽입
processed_docs = []

for item in data:
    full_text = item["document"]
    metadata = item["metadata"]
    summary = summarize(full_text)

    metadata["summary"] = summary

    doc = Document(page_content=summary, metadata=metadata)
    processed_docs.append(doc)

# ✅ Chroma DB에 추가
if processed_docs:
    db.add_documents(processed_docs)
    print(f"✅ {len(processed_docs)}개의 문서가 요약되어 DB에 추가되었습니다.")
else:
    print("🚨 추가할 문서가 없습니다.")
