from fastapi import FastAPI
from pydantic import BaseModel
from langchain_community.llms import OllamaLLM  # langchain-community에서 제공
from langchain_community.vectorstores import Chroma  # langchain-community에서 제공
from langchain_community.embeddings import OllamaEmbeddings  # langchain-community에서 제공
from langchain.chains import RetrievalQA

app = FastAPI()

embedding = OllamaEmbeddings()
db = Chroma(persist_directory="db", embedding_function=embedding)
retriever = db.as_retriever()

llm = OllamaLLM(model="llama3")  # langchain-community에서 제공

qa = RetrievalQA.from_chain_type(llm=llm, retriever=retriever)

class RAGRequest(BaseModel):
    category: str

@app.post("/recommend")
async def recommend(req: RAGRequest):
    query = f"{req.category} 운동 좋아하는 사람에게 오늘 할 만한 운동 추천해줘"
    response = qa.run(query)
    return {"message": response}

