import json
import os
from langchain_community.vectorstores import Chroma
from langchain.schema import Document
from langchain_ollama import OllamaEmbeddings
from langchain_chroma import Chroma

# ✅ 파일 및 경로 설정
json_file = "naver_blog_data.json"
persist_directory = "/chroma/chroma"

# ✅ Chroma 및 임베딩 초기화
embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="llama3")
db = Chroma(persist_directory=persist_directory, embedding_function=embedding)

# ✅ 기존 문서 삭제
existing = db.get()
ids = existing["ids"]
if ids:
    db.delete(ids=ids)
    print(f"🧹 기존 문서 {len(ids)}개 삭제 완료")

# ✅ JSON 로드
with open(json_file, "r", encoding="utf-8") as f:
    data = json.load(f)

# ✅ 문서 파싱
documents = data.get("documents", [])

docs = []
for item in documents:
    content = item.get("document")
    metadata = item.get("metadata", {})
    if content:  # 빈 문서 제외
        docs.append(Document(page_content=content, metadata=metadata))

# ✅ Chroma에 저장
if docs:
    db.add_documents(docs)
    print(f"✅ {len(docs)}개의 문서가 DB에 추가되었습니다.")
else:
    print("❌ 추가할 유효한 문서가 없습니다.")