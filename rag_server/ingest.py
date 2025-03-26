from langchain.vectorstores import Chroma
from langchain.embeddings import OpenAIEmbeddings
from langchain.document_loaders import TextLoader
from langchain.text_splitter import CharacterTextSplitter
import os

loader = TextLoader("documents/walking.txt")
docs = loader.load()

splitter = CharacterTextSplitter(chunk_size=500, chunk_overlap=0)
split_docs = splitter.split_documents(docs)

embedding = OpenAIEmbeddings(openai_api_key=os.getenv("OPENAI_API_KEY"))
Chroma.from_documents(split_docs, embedding, persist_directory="db")
print("✅ Chroma에 문서 임베딩 완료")
