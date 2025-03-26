from fastapi import FastAPI
from pydantic import BaseModel
from langchain_ollama import OllamaLLM  # langchain-ollama에서 OllamaLLM 사용
from langchain_chroma import Chroma  # langchain-chroma에서 Chroma 사용
from langchain_ollama import OllamaEmbeddings  # langchain-ollama에서 OllamaEmbeddings 사용
from langchain.chains import RetrievalQA

app = FastAPI()

embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="llama3")  # 모델 명을 추가
db = Chroma(persist_directory="db", embedding_function=embedding)
retriever = db.as_retriever()

llm = OllamaLLM(base_url="http://ollama:11434", model="llama3")  # Ollama 모델 사용

qa = RetrievalQA.from_chain_type(llm=llm, retriever=retriever)

class RAGRequest(BaseModel):
    category: str

@app.post("/recommend")
async def recommend(req: RAGRequest):
    query = f"{req.category} 운동 좋아하는 사람에게 오늘 할 만한 운동 추천해줘"
    response = qa.run(query)
    return {"message": response}

