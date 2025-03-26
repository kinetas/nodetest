import hashlib
import os
from langchain_ollama import OllamaEmbeddings
from langchain_chroma import Chroma
from langchain.document_loaders import TextLoader
from langchain.text_splitter import CharacterTextSplitter

# 문서 폴더와 DB 설정
docs_folder = "documents"
persist_directory = "db"

# Ollama Embedding
embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="llama3")

# 기존 DB 로드 (없으면 자동 생성)
db = Chroma(persist_directory=persist_directory, embedding_function=embedding)

# 문서에서 고유 해시값 생성 (중복 방지용)
def get_doc_hash(text):
    return hashlib.md5(text.encode('utf-8')).hexdigest()

existing_hashes = set()

# 기존 DB의 문서 해시값을 가져오기
for doc in db.get()['documents']:
    existing_hashes.add(get_doc_hash(doc))

# 새로운 문서 로드
new_docs = []
for filename in os.listdir(docs_folder):
    if filename.endswith(".txt"):
        filepath = os.path.join(docs_folder, filename)
        loader = TextLoader(filepath)
        docs = loader.load()

        splitter = CharacterTextSplitter(chunk_size=500, chunk_overlap=0)
        split_docs = splitter.split_documents(docs)

        for doc in split_docs:
            doc_hash = get_doc_hash(doc.page_content)
            if doc_hash not in existing_hashes:
                new_docs.append(doc)
                existing_hashes.add(doc_hash)  # 추가한 후 해시 추가 (중복 방지)

# 새로운 문서만 DB에 추가
if new_docs:
    db.add_documents(new_docs)
    db.persist()
    print(f"✅ {len(new_docs)}개의 새로운 문서가 DB에 추가되었습니다.")
else:
    print("🚨 추가할 새로운 문서가 없습니다.")

