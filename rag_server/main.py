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


# from fastapi import FastAPI
# from fastapi.responses import JSONResponse
# from pydantic import BaseModel
# from dotenv import load_dotenv
# import os, requests, re, json, time
# from langchain_chroma import Chroma
# from langchain_ollama import OllamaEmbeddings
# from fastapi.staticfiles import StaticFiles
# from fastapi.responses import FileResponse


# # 환경 설정
# load_dotenv()
# GROQ_API_KEY = os.getenv("GROQ_API_KEY")
# GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"

# # FastAPI
# app = FastAPI()

# # 임베딩 & 벡터 DB
# embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="llama3")
# db = Chroma(persist_directory="/chroma/chroma", embedding_function=embedding)

# class ChatRequest(BaseModel):
#     category: str

# @app.post("/recommend")
# async def recommend(req: ChatRequest):
#     start_time = time.time()
#     query = f"{req.category} 오늘 해볼 만한 미션 하나 추천해줘."

#     # 🔍 문서 검색
#     docs_with_scores = db.similarity_search_with_score(query, k=4)
#     filtered_docs = [doc for doc, score in docs_with_scores if score < 0.53]
#     context = "\n\n".join([doc.page_content for doc in filtered_docs])

#     # 💬 프롬프트 생성
#     if len(filtered_docs) >= 1:
#         # ✅ RAG 기반 프롬프트
#         final_prompt = (
#             "너는 사용자의 요청을 참고 문서를 바탕으로 미션을 추천하는 AI야.아래 JSON 형식으로만 응답하고, JSON 외에는 아무 것도 출력하지 마.\n\n"
#             "message 항목은 사용자에게 자연스럽고 부드러운 문장이어야 해. \n"
#             "단, 아래는 예시일 뿐이니 절대로 복사하지 마:\n"
#             '예시: "책상 정리를 해보는 건 어때요? 마음도 함께 정리될 거예요."\n\n'
#             "다음 JSON 형식으로만 응답해:\n"
#             '{\n'
#             '  "message": "자연어 문장",\n'
#             '  "category": "카테고리"\n'
#             "}\n\n"
#             f"참고 문서:\n{context}\n\n"
#             f"사용자 요청: {query}"
#         )
#     else:
#         # ✅ CoT 프롬프트
#         final_prompt = (
#             "너는 미션 추천 AI야. 아래 JSON 형식으로만 응답하고, JSON 외에는 아무 것도 출력하지 마.\n\n"
#             "message 항목은 사용자의 요청에 맞는 카테고리를 분석하고 그 카테고리가 어떤 특징과 효과가 있는지 알려주고 그에 따른 미션을 추천해주고 그게 왜 카테고리의 특징이나 효과와 관련있는지 근거를 자연스럽고 부드러운 문장으로 말해줘. \n"
#             "단, 아래는 예시일 뿐이니 절대로 복사하지 마:\n"
#             '예시: "책상 정리를 해보는 건 어때요? 마음도 함께 정리될 거예요."\n\n'
#             "category 항목은 해당 미션의 카테고리를 하나로 요약해서 넣어. (예: 운동, 감정관리, 자기관리, 집중 등)\n\n"
#             "다음 JSON 형식으로만 응답해:\n"
#             '{\n'
#             '  "message": "자연어 문장",\n'
#             '  "category": "카테고리"\n'
#             "}\n\n"
#             f"사용자 요청: {query}"
#         )

#     # 🚀 Groq API 호출
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
#         result = response.json()
#         content = result["choices"][0]["message"]["content"]

#         # 🧠 JSON 파싱
#         json_match = re.search(r"\{.*\}", content, re.DOTALL)
#         if not json_match:
#             raise ValueError("응답에서 JSON을 찾을 수 없습니다.")
#         json_str = json_match.group(0).replace("'", '"')
#         parsed = json.loads(json_str)

#         parsed["response_time_sec"] = round(time.time() - start_time, 2)
#         return parsed

#     except json.JSONDecodeError as json_err:
#         return JSONResponse(status_code=500, content={
#             "error": "JSON 파싱 실패",
#             "detail": str(json_err),
#             "raw_content": content
#         })
#     except Exception as e:
#         return JSONResponse(status_code=500, content={"error": str(e)})

# # ✅ Chroma 문서 리스트 확인용
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

# # ✅ 정적 파일 서빙 (HTML 포함)
# app.mount("/static", StaticFiles(directory="static"), name="static")

# @app.get("/")
# def serve_index():
#     return FileResponse("static/index.html")


from fastapi import FastAPI
from fastapi.responses import JSONResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from dotenv import load_dotenv
import os, requests, json, re, time
from bs4 import BeautifulSoup
from langchain_community.vectorstores import Chroma
# from langchain_ollama import OllamaEmbeddings
from langchain.embeddings import HuggingFaceEmbeddings
from langchain_community.embeddings import HuggingFaceEmbeddings

# ✅ 환경 변수 로딩
load_dotenv()
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"

# ✅ FastAPI 초기화
app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/")
def serve_index():
    return FileResponse("static/index.html")

# ✅ 벡터 DB 및 임베딩 올라마버전
# embedding = OllamaEmbeddings(base_url="http://ollama:11434", model="nomic-embed-text")
# db = Chroma(persist_directory="/chroma/chroma", embedding_function=embedding)

embedding = HuggingFaceEmbeddings(
    model_name="jhgan/ko-sroberta-multitask",
    model_kwargs={"device": "cpu"},
    encode_kwargs={"normalize_embeddings": True}
)
db = Chroma(persist_directory="/chroma/chroma", embedding_function=embedding)

# ✅ 블로그 본문 크롤링 함수
def crawl_naver_blog(url):
    headers = {"User-Agent": "Mozilla/5.0"}
    try:
        time.sleep(3) 
        res = requests.get(url, headers=headers, timeout=10)
        soup = BeautifulSoup(res.text, "html.parser")

        iframe = soup.select_one("iframe#mainFrame")
        if iframe:
            iframe_url = "https://blog.naver.com" + iframe["src"]
            res2 = requests.get(iframe_url, headers=headers, timeout=10)
            soup2 = BeautifulSoup(res2.text, "html.parser")
            content_div = soup2.select_one("div.se-main-container")
            if content_div:
                return content_div.get_text("\n", strip=True)
        else:
            content_div = soup.select_one("div.se-main-container")
            if content_div:
                return content_div.get_text("\n", strip=True)
    except Exception as e:
        print("❌ 크롤링 실패:", e)
    return None

# ✅ API 모델
class ChatRequest(BaseModel):
    category: str

@app.post("/recommend")
async def recommend(req: ChatRequest):
    start_time = time.time()
    query = f"{req.category} 관련해서 오늘 해볼 만한 미션 하나 추천해줘."

    # 🔍 RAG 검색
    docs_with_scores = db.similarity_search_with_score(query, k=4)
    print("🔍 유사도 검색 결과:")
    for i, (doc, score) in enumerate(docs_with_scores):
        content = doc.page_content or "(⚠️ 내용 없음)"
        try:
            preview = content[:100].replace('\n', ' ')
        except Exception as e:
            preview = f"(⚠️ 출력 실패: {e})"
        print(f"  {i+1}. 점수: {score:.4f}")
        print(f"     요약: {preview}")
        print(f"     출처: {doc.metadata.get('source', '(없음)')}")
    filtered_docs = [doc for doc, score in docs_with_scores if score < 1.1]

    if not filtered_docs:
        # ✅ fallback - CoT 방식
        prompt = (
            "너는 미션 추천 AI야. 아래 JSON 형식으로만 응답하고, JSON 외에는 아무 것도 출력하지 마.\n"
            'message 항목은 사용자의 요청에 맞는 카테고리를 분석하고 그 카테고리가 어떤 특징과 효과가 있는지 알려주고 그에 따른 미션을 추천해주고 그게 왜 카테고리의 특징이나 효과와 관련있는지 근거를 자연스럽고 부드러운 문장으로 미션추천줘."\n\n'
            "category 항목은 해당 미션의 카테고리를 하나로 요약해서 넣어. (예: 운동, 감정관리, 자기관리, 집중 등)\n\n"
            "다음 JSON 형식으로만 응답해:\n"
            '{\n'
            '  "message": "자연어 문장으로된 미션추천",\n'
            '  "category": "카테고리"\n'
            "}\n\n"
            f"사용자 요청: {query}"
        )
    else:
        # ✅ 첫 문서에서 본문 크롤링
        url = filtered_docs[0].metadata.get("source")
        blog_text = crawl_naver_blog(url) or ""
        print(f"\n🌐 선택된 문서 URL: {url}")

        blog_text = crawl_naver_blog(url) or ""
        print(f"📄 크롤링된 블로그 본문 길이: {len(blog_text)}자")
        print(f"📄 본문 일부:\n{blog_text[:500]}...\n")  # ← 이게 핵심!

        prompt = (
            "너는 사용자의 요청을 참고 문서를 바탕으로 미션을 추천하는 AI야.\n"
            "아래 JSON 형식으로만 응답하고, JSON 외에는 아무 것도 출력하지 마.\n\n"
            "message 항목은 참고 블로그 본문의 내용을 보고 그게 왜 카테고리와 어떤 관련이 있고 어떤 효과가 있는지 말해야 하며 4~5줄 정도 되도록 길고 자연스럽고 부드러운 문장으로 미션을 추천해야해.\n"
            # '예시: "책상 정리를 해보는 건 어때요? 마음도 함께 정리될 거예요."\n\n'
            "다음 JSON 형식으로만 응답해:\n"
            '{\n'
            '  "message": "자연어 문장으로 된 미션추천",\n'
            '  "category": "카테고리"\n'
            "}\n\n"
            f"참고 블로그 본문:\n{blog_text[:3000]}\n\n"
            f"사용자 요청: {query}"
        )

    # ✅ Groq API 호출
    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json"
    }
    body = {
        "model": "llama3-8b-8192",
        "messages": [{"role": "user", "content": prompt}],
        "temperature": 0.7
    }

    try:
        response = requests.post(GROQ_API_URL, headers=headers, json=body)
        result = response.json()
        content = result["choices"][0]["message"]["content"]

        json_match = re.search(r"\{.*\}", content, re.DOTALL)
        if not json_match:
            raise ValueError("응답에서 JSON을 찾을 수 없습니다.")

        parsed = json.loads(json_match.group(0).replace("'", '"'))
        parsed["response_time_sec"] = round(time.time() - start_time, 2)
        return parsed

    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})

# ✅ 디버깅용 문서 확인용 API
@app.get("/documents")
async def get_documents():
    try:
        data = db.get()
        documents_info = []
        for i in range(len(data["ids"])):
            doc = {
                "id": data["ids"][i],
                "document": data["documents"][i],
                "metadata": data["metadatas"][i]
            }
            documents_info.append(doc)
        return JSONResponse(content={"documents": documents_info})
    except Exception as e:
        return JSONResponse(status_code=500, content={"error": str(e)})