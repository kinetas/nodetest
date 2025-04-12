# ✅ Dockerfile for intent-classifier microservice
FROM python:3.10-slim

WORKDIR /app
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pm2

# requirements.txt 설치를 위한 복사
COPY requirements.txt ./
COPY fine_tuned_intent_model.py ./
COPY intent_data.csv ./
COPY intent_classifier.py ./

# pip 최신화 및 필수 패키지 설치
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
RUN pip install 'numpy<2'

RUN python3 fine_tuned_intent_model.py

# 프로젝트 파일 복사
COPY . .

# FastAPI 실행 포트
EXPOSE 8002

CMD ["pm2-runtime", "uvicorn", "--", "intent_classifier:app", "--host", "0.0.0.0", "--port", "8002"]
