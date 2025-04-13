FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt ./
COPY fine_tuned_intent_model.py ./
COPY intent_data.csv ./
COPY intent_classifier.py ./
# apt 업데이트 및 curl, nodejs, npm 설치
RUN apt-get update && \
    apt-get install -y curl gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pm2

RUN pip install 'numpy<2'
# 파이썬 패키지 설치
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 사전 학습 모델 생성
# RUN python3 fine_tuned_intent_model.py

# PM2로 FastAPI 실행
CMD ["pm2-runtime", "uvicorn", "--", "intent_classifier:app", "--host", "0.0.0.0", "--port", "8002"]

# model이 없을 때 실행
# CMD ["tail", "-f", "/dev/null"]  

# COPY start.sh ./start.sh
# RUN chmod +x start.sh
# CMD ["./start.sh"]


