import json
from langchain_community.vectorstores import Chroma
from langchain.schema import Document
from langchain_ollama import OllamaEmbeddings
from langchain_chroma import Chroma
import os

# 경로 설정
json_file = "naver_blog_data.json"
persist_directory = "/chroma/chroma"

# 임베딩 초기화 (로컬 서버의 llama3 사용)
embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="llama3")
db = Chroma(persist_directory=persist_directory, embedding_function=embedding)

# 기존 문서 삭제
existing = db.get()
ids = existing["ids"]
if ids:
    db.delete(ids=ids)
    print(f"🧹 기존 문서 {len(ids)}개 삭제 완료")

# JSON 로드
with open(json_file, "r", encoding="utf-8") as f:
    data = json.load(f)

# 문서 가공
docs = [
    Document(page_content=item["document"], metadata=item["metadata"])
    for item in data
]

# DB에 저장
db.add_documents(docs)
print(f"✅ {len(docs)}개의 문서가 DB에 추가되었습니다.")
