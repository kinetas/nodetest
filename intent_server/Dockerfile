# ✅ Dockerfile for intent-classifier microservice
FROM python:3.10-slim

WORKDIR /app

# requirements.txt 설치를 위한 복사
COPY requirements.txt ./

# pip 최신화 및 필수 패키지 설치
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
RUN pip install numpy<2


# 프로젝트 파일 복사
COPY . .

# FastAPI 실행 포트
EXPOSE 8002

CMD ["uvicorn", "intent_classifier:app", "--host", "0.0.0.0", "--port", "8002"]
