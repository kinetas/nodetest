import json
from langchain_community.vectorstores import Chroma
from langchain.schema import Document
# from langchain_ollama import OllamaEmbeddings
import hashlib
import os
from langchain_community.document_loaders import TextLoader
from langchain.text_splitter import CharacterTextSplitter
from langchain_chroma import Chroma
from langchain.embeddings import HuggingFaceEmbeddings
from langchain_community.embeddings import HuggingFaceEmbeddings

# 경로 설정
#json_file = "documents/data.json"  # 👈 여기에 JSON 저장
json_file="naver_blog_data.json" #크롤링버전
persist_directory = "/chroma/chroma"

# try:
#     if os.path.exists(persist_directory):
#         shutil.rmtree(persist_directory)
#         print("✅ 기존 Chroma DB 디렉토리 삭제 완료")
# except Exception as e:
#     print(f"⚠️ 디렉토리 삭제 실패: {e}")

# 임베딩 초기화 올라마 버전전
# embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="llama3")
# db = Chroma(persist_directory=persist_directory, embedding_function=embedding)

embedding = HuggingFaceEmbeddings(
    model_name="jhgan/ko-sroberta-multitask",
    model_kwargs={"device": "cpu"},
    encode_kwargs={"normalize_embeddings": True}
)

db = Chroma(persist_directory=persist_directory, embedding_function=embedding)

existing = db.get()
ids = existing["ids"]
if ids:
    db.delete(ids=ids)
    print(f"🧹 기존 문서 {len(ids)}개 삭제 완료")

# # JSON 불러오기
# with open(json_file, "r", encoding="utf-8") as f:
#     data = json.load(f)#["documents"]  # 👈 이 부분만 바꾸면 바로 해결됨!

# docs = [
#     Document(page_content=item["document"], metadata=item["metadata"])
#     for item in data
# ]
with open(json_file, "r", encoding="utf-8") as f:
    data = json.load(f)

documents = data["documents"]  # 이걸로 리스트 추출

# 문서 가공
docs = [
    Document(page_content=item["document"], metadata=item["metadata"])
    for item in documents
]
# DB에 추가
db.add_documents(docs)
print(f"✅ {len(docs)}개의 문서가 DB에 추가되었습니다.")

