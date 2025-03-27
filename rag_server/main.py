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
# from fastapi import FastAPI
# from fastapi.responses import JSONResponse, FileResponse
# from fastapi.staticfiles import StaticFiles
# from pydantic import BaseModel
# import os
# import requests
# from dotenv import load_dotenv
# load_dotenv()

# app = FastAPI()

# class RAGRequest(BaseModel):
#     category: str

# GROQ_API_KEY = os.getenv("GROQ_API_KEY")
# GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"

# @app.post("/recommend")
# async def recommend(req: RAGRequest):
#     prompt = f"{req.category} 오늘 해볼 만한 미션 2가지 추천해줘. 반드시 한국어로 짧게 말해줘."

#     headers = {
#         "Authorization": f"Bearer {GROQ_API_KEY}",
#         "Content-Type": "application/json"
#     }

#     body = {
#         "model": "llama3-8b-8192",
#         "messages": [
#             {"role": "user", "content": prompt}
#         ],
#         "temperature": 0.7
#     }

#     try:
#         response = requests.post(GROQ_API_URL, headers=headers, json=body)
#         response.raise_for_status()
#         result = response.json()
#         message = result["choices"][0]["message"]["content"]
#         return {"message": message}
#     except Exception as e:
#         return JSONResponse(status_code=500, content={"error": str(e)})

# # 아래는 그대로 유지
# from langchain_chroma import Chroma
# from langchain_ollama import OllamaEmbeddings

# embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="llama3")
# db = Chroma(persist_directory="/chroma/chroma", embedding_function=embedding)

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

# ✅ .env 파일 로드
load_dotenv()

# ✅ Groq API 설정
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"

# ✅ FastAPI 인스턴스 생성
app = FastAPI()

# ✅ Pydantic 모델
class RAGRequest(BaseModel):
    category: str

# ✅ Chroma (문서 검색용)
from langchain_chroma import Chroma
from langchain_ollama import OllamaEmbeddings

# ⚠️ Ollama는 임베딩용으로만 사용됨 (서버 필요)
embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="llama3")
db = Chroma(persist_directory="/chroma/chroma", embedding_function=embedding)
retriever = db.as_retriever()

# ✅ 추천 API (RAG 구조 적용)
@app.post("/recommend")
async def recommend(req: RAGRequest):
    query = f"{req.category} 오늘 해볼 만한 미션 2가지 추천해줘. 반드시 한국어로 짧게 말해줘."

    # 1. 문서 검색
    relevant_docs = retriever.get_relevant_documents(query)
    context = "\n\n".join([doc.page_content for doc in relevant_docs])

    # 2. 프롬프트 구성
    final_prompt = (
        f"다음은 참고 문서입니다:\n\n{context}\n\n"
        f"위 문서를 참고하여 다음 질문에 대해 한국어로 짧게 추천해주세요:\n\n{query}"
    )

    # 3. Groq API 호출
    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json"
    }

    body = {
        "model": "llama3-8b-8192",
        "messages": [{"role": "user", "content": final_prompt}],
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

# ✅ Chroma 문서 리스트 확인용
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

# ✅ 정적 파일 서빙 (HTML 포함)
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/")
def serve_index():
    return FileResponse("static/index.html")