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
import random

# ✅ 환경 변수 로딩
load_dotenv()
GROQ_API_KEY = os.getenv("GROQ_API_KEY")
GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"

# ✅ FastAPI 초기화
app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/ai")
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

@app.post("/ai/recommend")
async def recommend(req: ChatRequest):
    start_time = time.time()
    query = f"{req.category} 관련해서 오늘 해볼 만한 미션 하나 추천해줘."

    # 🔍 RAG 검색
    docs_with_scores = db.similarity_search_with_score(query, k=10)
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
    filtered_docs_with_scores = [(doc, score) for doc, score in docs_with_scores if score < 1.2]

    if not filtered_docs_with_scores:
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
        # 2. 점수 차이가 거의 없다면 랜덤 선택
        if len(filtered_docs_with_scores) >= 2 and abs(filtered_docs_with_scores[0][1] - filtered_docs_with_scores[1][1]) < 0.03:
            selected_doc = random.choice(filtered_docs_with_scores)[0]
        else:
            selected_doc = filtered_docs_with_scores[0][0]  # 유사도 1등 문서
        url = selected_doc.metadata.get("source")
        blog_text = crawl_naver_blog(url) or ""
        print(f"\n🌐 선택된 문서 URL: {url}")

        blog_text = crawl_naver_blog(url) or ""
        print(f"📄 크롤링된 블로그 본문 길이: {len(blog_text)}자")
        print(f"📄 본문 일부:\n{blog_text[:500]}...\n")  # ← 이게 핵심!

        prompt = (
            "너는 사용자의 요청을 참고 문서를 바탕으로 미션을 추천하는 AI야.\n"
            "아래 JSON 형식으로만 응답하고, JSON 외에는 아무 것도 출력하지 마.\n\n"
            "message 항목은 참고 블로그 본문의 내용을 보고 그걸 그대로 사용하지 말고 카테고리와 관련해서 어떤 관련이 있고, 어떤 종류가 있고, 어떤 효과나 영향이 있는지 말해야 하며, 이를 4~5줄 정도 되도록 반드시 길고 자연스럽고 부드러운 문장으로 미션을 추천해야해. 또한 왜 카테고리가 해당 답변이 어떤 관련이 있는지 분석 후 말하는 것도 있어야해.\n"
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
@app.get("/ai/documents")
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