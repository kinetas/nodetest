# rag_server/Dockerfile
FROM python:3.10

WORKDIR /app

# pm2 설치용 Node 설치
RUN apt update && apt install -y curl gnupg
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt install -y nodejs
RUN npm install -g pm2

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# pm2로 uvicorn 실행 (FastAPI 서버 실행)
# CMD ["pm2-runtime", "start", "main.py", "--interpreter", "python3", "--", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
CMD ["pm2-runtime", "start", "uvicorn", "--interpreter", "python3", "--", "main:app", "--host", "0.0.0.0", "--port", "8000"]

