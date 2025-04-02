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

# from fastapi import FastAPI
# from fastapi.responses import JSONResponse, FileResponse
# from fastapi.staticfiles import StaticFiles
# from pydantic import BaseModel
# import os
# import requests
# from dotenv import load_dotenv
# import time

# # ✅ .env 파일 로드
# load_dotenv()

# # ✅ Groq API 설정
# GROQ_API_KEY = os.getenv("GROQ_API_KEY")
# GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"

# # ✅ FastAPI 인스턴스 생성
# app = FastAPI()

# # ✅ Pydantic 모델
# class RAGRequest(BaseModel):
#     category: str

# # ✅ Chroma (문서 검색용)
# from langchain_chroma import Chroma
# from langchain_ollama import OllamaEmbeddings

# # ⚠️ Ollama는 임베딩용으로만 사용됨 (서버 필요)
# embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="llama3")
# db = Chroma(persist_directory="/chroma/chroma", embedding_function=embedding)

# # ✅ 추천 API (RAG 구조 적용)

# @app.post("/recommend")
# async def recommend(req: RAGRequest):
#     start_time = time.time()
#     query = f"{req.category} 카테고리와 관련된 오늘 해볼 만한 미션 2가지 추천해줘. 반드시 한국어로 짧게 말해줘."

#     # 1. 문서 검색
#     docs_with_scores = db.similarity_search_with_score(query, k=4)

#     for doc, score in docs_with_scores:
#         print(f"문서 유사도 점수: {score:.4f} / 문서: {doc.page_content[:30]}...")


#     # 2. 유사도 필터링 (점수 낮을수록 관련 있음)
#     filtered_docs = [doc for doc, score in docs_with_scores if score < 0.53]
#     context = "\n\n".join([doc.page_content for doc in filtered_docs])

#     # 3. 문서가 충분하면 RAG, 아니면 Groq 단독
#     is_rag = len(filtered_docs) >= 1 #and len(context) > 50

#     if is_rag:
#         final_prompt = (
#             f"다음은 참고 문서입니다:\n\n{context}\n\n"
#             f"위 문서를 참고하여 다음 질문에 대해 한국어로 짧게 추천해주세요:\n\n{query}"
#         )
#     else:
#         final_prompt = query

#     # 4. Groq API 호출
#     headers = {
#         "Authorization": f"Bearer {GROQ_API_KEY}",
#         "Content-Type": "application/json"
#     }

#     body = {
#         "model": "llama3-8b-8192",
#         "messages": [{"role": "user", "content": final_prompt}],
#         "temperature": 0.7
#     }

#     try:
#         response = requests.post(GROQ_API_URL, headers=headers, json=body)
#         response.raise_for_status()
#         result = response.json()
#         message = result["choices"][0]["message"]["content"]
#         end_time = time.time()  # ⏱️ 끝 시각
#         elapsed_time = round(end_time - start_time, 2)  # 소수 2자리까지
#         return {"message": message, "response_time_sec": elapsed_time}

#     except Exception as e:
#         return JSONResponse(status_code=500, content={"error": str(e)})

# RAG만 사용용

# @app.post("/recommend")
# async def recommend(req: RAGRequest):
#     start_time = time.time()
#     query = f"{req.category} 오늘 해볼 만한 미션 2가지 추천해줘. 반드시 한국어로 짧게 말해줘."

#     headers = {
#         "Authorization": f"Bearer {GROQ_API_KEY}",
#         "Content-Type": "application/json"
#     }

#     body = {
#         "model": "llama3-8b-8192",
#         "messages": [{"role": "user", "content": query}],
#         "temperature": 0.7
#     }

#     try:
#         response = requests.post(GROQ_API_URL, headers=headers, json=body)
#         result = response.json()
#         message = result["choices"][0]["message"]["content"]
#         end_time = time.time()  # ⏱️ 끝 시각
#         elapsed_time = round(end_time - start_time, 2)  # 소수 2자리까지
#         return {"message": message, "response_time_sec": elapsed_time}
#     except Exception as e:
#         return JSONResponse(status_code=500, content={"error": str(e)})

# CoT

# @app.post("/recommend")
# async def recommend(req: RAGRequest):
#     start_time = time.time()
#     user_input = f"{req.category} 오늘 해볼 만한 미션 2가지 추천해줘."

#     cot_prompt = (
#         "너는 사용자의 요청을 분석해 미션을 추천하는 AI야. "
#         "먼저 카테고리를 분석하고, 그 카테고리의 효과나 특징을 한 줄로 요약한 후, "
#         "그에 맞는 미션을 2가지 추천해주고 그게 왜 카테고리의 효과나 특징과 맞는지 근거를 말해줘. 반드시 단계별로 생각하고 마지막에 최종 결과를 정리해서 한국어로 말해줘. \n\n"
#         f"사용자 요청: {user_input}"
#     )

#     headers = {
#         "Authorization": f"Bearer {GROQ_API_KEY}",
#         "Content-Type": "application/json"
#     }

#     body = {
#         "model": "llama3-8b-8192",
#         "messages": [{"role": "user", "content": cot_prompt}],
#         "temperature": 0.7
#     }

#     try:
#         response = requests.post(GROQ_API_URL, headers=headers, json=body)
#         result = response.json()
#         message = result["choices"][0]["message"]["content"]
#         end_time = time.time()  # ⏱️ 끝 시각
#         elapsed_time = round(end_time - start_time, 2)  # 소수 2자리까지
#         return {"message": message, "response_time_sec": elapsed_time}
#     except Exception as e:
#         return JSONResponse(status_code=500, content={"error": str(e)})


from fastapi import FastAPI
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from dotenv import load_dotenv
import os, requests, re, json, time
from langchain_chroma import Chroma
from langchain_ollama import OllamaEmbeddings
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse


# 환경 설정
load_dotenv()
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"

# FastAPI
app = FastAPI()

# 임베딩 & 벡터 DB
embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="llama3")
db = Chroma(persist_directory="/chroma/chroma", embedding_function=embedding)

class ChatRequest(BaseModel):
    category: str

@app.post("/recommend")
async def recommend(req: ChatRequest):
    start_time = time.time()
    query = f"{req.category} 오늘 해볼 만한 미션 2가지 추천해줘."

    # 🔍 문서 검색
    docs_with_scores = db.similarity_search_with_score(query, k=4)
    filtered_docs = [doc for doc, score in docs_with_scores if score < 0.53]
    context = "\n\n".join([doc.page_content for doc in filtered_docs])

    # 💬 프롬프트 생성
    if len(filtered_docs) >= 1:
        # ✅ RAG 기반 프롬프트
        final_prompt = (
            "너는 사용자의 요청을 참고 문서를 바탕으로 미션을 추천하는 AI야.\n"
            "반드시 아래 JSON 형식으로 응답해. 설명은 자연어로 하고, JSON만 포함해줘.\n"
            '{\n'
            '  "message": "2가지 추천을 자연어로 설명",\n'
            '  "category": "해당 추천이 속하는 카테고리 (예: 운동, 감정관리, 자기관리, 집중 등)"\n'
            "}\n\n"
            f"참고 문서:\n{context}\n\n"
            f"사용자 요청: {query}"
        )
    else:
        # ✅ CoT 프롬프트
        final_prompt = (
            "너는 미션 추천 AI야. 반드시 아래 JSON 형식으로만 응답해. 설명하지 마.\n"
            '{\n'
            '  "message": "2가지 추천을 자연어로 설명",\n'
            '  "category": "해당 추천이 속하는 카테고리 (예: 운동, 감정관리, 자기관리, 집중 등)"\n'
            "}\n\n"
            f"사용자 요청: {query}"
        )

    # 🚀 Groq API 호출
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
        result = response.json()
        content = result["choices"][0]["message"]["content"]

        # 🧠 JSON 파싱
        json_match = re.search(r"\{.*\}", content, re.DOTALL)
        if not json_match:
            raise ValueError("응답에서 JSON을 찾을 수 없습니다.")
        json_str = json_match.group(0).replace("'", '"')
        parsed = json.loads(json_str)

        parsed["response_time_sec"] = round(time.time() - start_time, 2)
        return parsed

    except json.JSONDecodeError as json_err:
        return JSONResponse(status_code=500, content={
            "error": "JSON 파싱 실패",
            "detail": str(json_err),
            "raw_content": content
        })
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