# import hashlib
# import os
# from langchain_community.document_loaders import TextLoader
# from langchain.text_splitter import CharacterTextSplitter
# from langchain_ollama import OllamaEmbeddings
# from langchain_chroma import Chroma

# # 폴더 및 DB 설정
# docs_folder = "documents"
# persist_directory = "db"

# # Ollama Embedding 초기화
# embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="llama3")

# # DB 로드 또는 생성
# db = Chroma(persist_directory="/chroma/chroma", embedding_function=embedding)

# # 해시값 생성 함수 (중복 방지)
# def get_doc_hash(text):
#     return hashlib.md5(text.encode('utf-8')).hexdigest()

# existing_hashes = {get_doc_hash(doc) for doc in db.get()['documents']}

# # 새 문서 로드
# new_docs = []
# for filename in os.listdir(docs_folder):
#     if filename.endswith(".txt"):
#         filepath = os.path.join(docs_folder, filename)
#         loader = TextLoader(filepath)
#         docs = loader.load()

#         splitter = CharacterTextSplitter(chunk_size=500, chunk_overlap=0)
#         split_docs = splitter.split_documents(docs)

#         for doc in split_docs:
#             doc_hash = get_doc_hash(doc.page_content)
#             if doc_hash not in existing_hashes:
#                 new_docs.append(doc)
#                 existing_hashes.add(doc_hash)

# # DB에 추가
# if new_docs:
#     db.add_documents(new_docs)
#     print(f"✅ {len(new_docs)}개의 새로운 문서가 DB에 추가되었습니다.")
# else:
#     print("🚨 추가할 새로운 문서가 없습니다.")
import json
from langchain_community.vectorstores import Chroma
from langchain.schema import Document
from langchain_ollama import OllamaEmbeddings
import hashlib
import os
from langchain_community.document_loaders import TextLoader
from langchain.text_splitter import CharacterTextSplitter
from langchain_chroma import Chroma

# 경로 설정
json_file = "documents/data.json"  # 👈 여기에 JSON 저장
persist_directory = "/chroma/chroma"

# 임베딩 초기화
embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="llama3")
db = Chroma(persist_directory=persist_directory, embedding_function=embedding)

db._collection.delete()

# JSON 불러오기
with open(json_file, "r", encoding="utf-8") as f:
    data = json.load(f)

# Document 객체로 변환
docs = [
    Document(page_content=item["document"], metadata=item["metadata"])
    for item in data
]

# DB에 추가
db.add_documents(docs)
print(f"✅ {len(docs)}개의 문서가 DB에 추가되었습니다.")

