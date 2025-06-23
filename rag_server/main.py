from fastapi import FastAPI
from fastapi.responses import JSONResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from dotenv import load_dotenv
import os, requests, json, re, time, jwt
from fastapi import Request, HTTPException
from bs4 import BeautifulSoup
from langchain_community.vectorstores import Chroma
from langchain.embeddings import HuggingFaceEmbeddings
from langchain_community.embeddings import HuggingFaceEmbeddings
import random
import pymysql
from openai import OpenAI


# 환경 변수 로딩
load_dotenv()
USER_DB_API = "http://13.125.65.151:3000/nodetest/api/ai/user-top-categories"
INTENT_API = "http://intent_server:8002/intent-classify"
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
DB_HOST = os.getenv("AWS_DATABASE_HOST")
DB_USER = os.getenv("AWS_DATABASE_USER")
DB_PASSWORD = os.getenv("AWS_DATABASE_PASSWORD")
DB_NAME = os.getenv("AWS_DATABASE_NAME")
DB_PORT = int(os.getenv("AWS_DATABASE_PORT", 3306))


SECRET_KEY = os.getenv("JWT_SECRET_KEY")
if not SECRET_KEY:
    raise RuntimeError("❌ JWT_SECRET_KEY 환경변수가 설정되어 있지 않습니다.")

ALGORITHM = "HS256"  # RS256이 아니라면 이 값 유지

def extract_user_id_from_token(request: Request):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="토큰이 없습니다")

    token = auth_header.split(" ")[1]
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("userId")
        if not user_id:
            raise HTTPException(status_code=400, detail="user_id 없음")
        return user_id
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="토큰 만료됨")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="유효하지 않은 토큰")

# FastAPI 초기화
app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/")
def serve_index():
    return FileResponse("static/index.html")


embedding = HuggingFaceEmbeddings(
    model_name="jhgan/ko-sroberta-multitask",
    model_kwargs={"device": "cpu"},
    encode_kwargs={"normalize_embeddings": True}
)
db = Chroma(persist_directory="/chroma/chroma", embedding_function=embedding)


# 블로그 본문 크롤링 함수
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

# API 모델
class ChatRequest(BaseModel):
    category: str
   
@app.post("/recommend")
async def recommend(req: ChatRequest, request: Request):
    start_time = time.time()
    user_id = extract_user_id_from_token(request)
    user_input = req.category.strip()
    query = f"{req.category} 관련해서 오늘 해볼 만한 미션 하나 추천해줘."

    # 1 Intent 분류
    try:
        intent_res = requests.post(INTENT_API, json={"text": user_input}, timeout=2)
        intent = intent_res.json().get("intent", "SPECIFIC")
        print(f"🧠 Intent 분류 결과: {intent}")
    except:
        intent = "SPECIFIC"
        print(f"⚠️ Intent API 호출 실패: {e}")

    # 2️ GENERAL이면 user_db에서 top3 카테고리 요청
    # if intent == "GENERAL":
    #     try:
    #         user_res = requests.post(USER_DB_API, json={"user_id": user_id}, timeout=2)
    #         top3 = user_res.json().get("top3", [])
    #         print(f"📊 사용자 Top3 카테고리: {top3}")
    #         if top3:
    #             chosen = random.choice(top3)
    #             print(f"🎯 선택된 카테고리: {chosen}")
    #             query = f"{chosen} {query}"
                
    #     except:
    #         print(f"⚠️ User DB API 호출 실패: {e}")
    if intent == "GENERAL":
        try:
            conn = pymysql.connect(
                host=DB_HOST,
                user=DB_USER,
                password=DB_PASSWORD,
                database=DB_NAME,
                port=DB_PORT,
                charset='utf8mb4',
                cursorclass=pymysql.cursors.DictCursor
            )
            with conn:
                with conn.cursor() as cursor:
                    sql = """
                        SELECT category, COUNT(*) as cnt
                        FROM m_result
                        WHERE u_id = %s AND category IS NOT NULL
                        GROUP BY m_category
                        ORDER BY cnt DESC
                        LIMIT 3
                    """
                    cursor.execute(sql, (user_id,))
                    rows = cursor.fetchall()
                    top3 = [row['m_category'] for row in rows]

            print(f"📊 사용자 Top3 카테고리: {top3}")
            if top3:
                chosen = random.choice(top3)
                print(f"🎯 선택된 카테고리: {chosen}")
                query = f"{chosen} 관련해서 오늘 해볼 만한 미션 하나 추천해줘."
            else:
                query = f"오늘 해볼 만한 미션 하나 추천해줘."

        except Exception as e:
            print(f"⚠️ DB에서 카테고리 조회 실패: {e}")
            query = f"오늘 해볼 만한 미션 하나 추천해줘."


    # RAG 검색
    docs_with_scores = db.similarity_search_with_score(query, k=10)
    filtered_docs_with_scores = [(doc, score) for doc, score in docs_with_scores if score > 1]

    # Step 1 프롬프트 구성
    if not filtered_docs_with_scores:
        step1_prompt = (
            f"사용자 요청: {query}\n\n"
            "너는 사용자의 요청을 분석해 미션을 추천하는 AI야. "
            "먼저 카테고리를 분석하고, 그 카테고리의 효과나 특징을 한 줄로 요약한 후, "
            "그에 맞는 미션을 1가지 추천해주고 그게 왜 카테고리의 효과나 특징과 맞는지 근거를 말해줘. "
            "반드시 한국어로 부드럽고 자연스럽게 말해줘."
        )
        url = "(문서 없음)"
    else:
        top_n = max(3, len(filtered_docs_with_scores))  # 적절히 자르기
        selected_doc = random.choice(filtered_docs_with_scores[:top_n])[0]
        url = selected_doc.metadata.get("source")
        blog_text = crawl_naver_blog(url) or ""

        step1_prompt = (
            f"사용자 요청: {query}\n\n"
            f"참고 블로그 본문:\n{blog_text[:3000]}\n\n"
            "너는 블로그 본문을 바탕으로 미션을 추천하는 AI야. \n"
            "**단, 블로그 작성자의 개인 상황(예: 엄마, 육아, 직장, 성별, 가족 상황 등)에 너무 의존하지 말고, 모든 사람이 실천할 수 있는 일반적인 미션을 추천해야 해.**\n"
            "본문 내용을 반드시 참고해서 그 안의 핵심 문장이나 활동, 키워드 등을 분석하고, \n"
            "해당 내용을 반영하여 너가 1개의 미션을 반드시 한국어만 사용하여 창작하고 추천해줘. \n"
            "미션은 자연스럽고 부드러운 문장으로 한국어로만 설명하고, 추천 이유도 한국어로만 적어줘. \n"
            "절대로 본문 내용을 무시하거나 반대로 본문 내용을 그대로 사용하여 추천 하지 마. 반드시 본문 내용을 한국어만 사용해서 반영해야 해.\n"
            "결과는 반드시 자연어 한국어 문장만 제공해. JSON은 필요 없고 다시 말하지만 출력은 무조건 한국어로 해야해.\n\n"
        )

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",  # 또는 "gpt-3.5-turbo"
        messages=[{"role": "user", "content": step1_prompt}],
        temperature=0.7
    )
    # message = response["choices"][0]["message"]["content"]
    message = response.choices[0].message.content
    try:
        # res1 = requests.post(GROQ_API_URL, headers=headers, json=step1_body)
        # message = res1.json()["choices"][0]["message"]["content"].strip()
        print(" 생성된 미션 문장:\n", message)

        # Step 2: category + title만 생성
        step2_prompt = (
            "아래 미션 문장을 보고 category와 title을 반드시 **한국어**로 추출해서 단일 JSON 오브젝트 형식으로만 출력해.\n"
            "JSON 외에 다른 설명은 출력하지 마. 배열([]), 코드블럭(```), 마크다운도 절대 사용하지 마.\n"
            "형식 예시:\n"
            '{\n'
            '  "category": "카테고리",\n'
            '  "title": "미션 제목"\n'
            '}\n\n'
            f"미션 문장:\n{message}"
        )

        # step2_body = {
        #     "model": "llama3-8b-8192",
        #     "messages": [{"role": "user", "content": step2_prompt}],
        #     "temperature": 0.3
        # }
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": step2_prompt}],
            temperature=0.3
        )
        # content = response["choices"][0]["message"]["content"]
        content = response.choices[0].message.content
        # res2 = requests.post(GROQ_API_URL, headers=headers, json=step2_body)
        # content = res2.json()["choices"][0]["message"]["content"]
        print("📦 Step2 응답:\n", content)

        json_match = re.search(r"\{.*", content, re.DOTALL)
        if not json_match:
            raise ValueError("Step2 응답에서 JSON을 찾을 수 없습니다.")

        raw_json = json_match.group(0).replace("'", '"').replace('""', '"')

        # 중괄호 수 맞추기
        open_count = raw_json.count('{')
        close_count = raw_json.count('}')
        if open_count > close_count:
            raw_json += '}' * (open_count - close_count)

        parsed = json.loads(raw_json)

        # 최종 조합
        result = {
            "message": message,
            "category": parsed["category"],
            "title": parsed["title"],
            "source": url,
            "response_time_sec": round(time.time() - start_time, 2)
        }
        return result

    except Exception as e:
        return JSONResponse(status_code=500, content={
            "error": str(e),
            "raw_groq_response": content if 'content' in locals() else "응답 없음"
        })

# 디버깅용 문서 확인용 API
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
    
