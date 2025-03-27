# from fastapi import FastAPI
# from fastapi.responses import JSONResponse, FileResponse
# from fastapi.staticfiles import StaticFiles
# from pydantic import BaseModel
# from langchain_ollama import OllamaLLM
# from langchain_chroma import Chroma
# from langchain_ollama import OllamaEmbeddings
# from langchain.chains import RetrievalQA


# app = FastAPI()

# embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="llama3")
# db = Chroma(persist_directory="/chroma/chroma", embedding_function=embedding)  # 공유 볼륨 경로
# retriever = db.as_retriever()

# llm = OllamaLLM(base_url="http://ollama:11434", model="llama3")  # Ollama 모델 사용

# qa = RetrievalQA.from_chain_type(llm=llm, retriever=retriever)

# class RAGRequest(BaseModel):
#     category: str

# @app.post("/recommend")
# async def recommend(req: RAGRequest):
#     query = f"{req.category} 오늘 해볼 만한 미션 2가지 추천해줘. 반드시 한국어로 짧게 말해줘."
#     response = qa.run(query)
#     return {"message": response}

# @app.get("/documents")
# async def get_documents():
#     try:
#         data = db.get()
#         documents_info = []
#         for i in range(len(data['ids'])):
#             doc = {
#                 "id": data['ids'][i],
#                 "document": data['documents'][i],
#                 "metadata": data['metadatas'][i]
#             }
#             documents_info.append(doc)
#         return JSONResponse(content={"documents": documents_info})
#     except Exception as e:
#         return JSONResponse(status_code=500, content={"error": str(e)})

# # 정적 파일 서빙 설정
# app.mount("/static", StaticFiles(directory="static"), name="static")

# @app.get("/")
# def serve_index():
#     return FileResponse("static/index.html")
from fastapi import FastAPI
from fastapi.responses import JSONResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
import os
import requests
from dotenv import load_dotenv
load_dotenv()

app = FastAPI()

class RAGRequest(BaseModel):
    category: str

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"

@app.post("/recommend")
async def recommend(req: RAGRequest):
    prompt = f"{req.category} 오늘 해볼 만한 미션 2가지 추천해줘. 반드시 한국어로 짧게 말해줘."

    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json"
    }

    body = {
        "model": "llama3-8b-8192",
        "messages": [
            {"role": "user", "content": prompt}
        ],
        "temperature": 0.7
    }

    try:
        response = requests.post(GROQ_API_URL, headers=headers, json=body)
        response.raise_for_status()
        result = response.json()
        message = result["choices"][0]["message"]["content"]
        return {"message": message}
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

# 아래는 그대로 유지
from langchain_chroma import Chroma
from langchain_ollama import OllamaEmbeddings

embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="llama3")
db = Chroma(persist_directory="/chroma/chroma", embedding_function=embedding)

@app.get("/documents")
async def get_documents():
    try:
        data = db.get()
        documents_info = []
        for i in range(len(data['ids'])):
            doc = {
                "id": data['ids'][i],
                "document": data['documents'][i],
                "metadata": data['metadatas'][i]
            }
            documents_info.append(doc)
        return JSONResponse(content={"documents": documents_info})
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/")
def serve_index():
    return FileResponse("static/index.html")
