import json
from langchain_community.vectorstores import Chroma
from langchain.schema import Document
from langchain_ollama import OllamaEmbeddings
from langchain_chroma import Chroma
from dotenv import load_dotenv
import os

# ✅ 환경 변수 로드
load_dotenv()

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

# ✅ JSON 불러오기
with open(json_file, "r", encoding="utf-8") as f:
    data = json.load(f)["documents"]

# ✅ 문서 가공 (요약 없음)
processed_docs = []

for item in data:
    full_text = item["document"]
    metadata = item["metadata"]

    doc = Document(page_content=full_text, metadata=metadata)
    processed_docs.append(doc)

# ✅ Chroma DB에 추가
if processed_docs:
    db.add_documents(processed_docs)
    print(f"✅ {len(processed_docs)}개의 문서가 DB에 추가되었습니다.")
else:
    print("🚨 추가할 문서가 없습니다.")
