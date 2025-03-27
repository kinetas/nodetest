# 1. Python 3.10 기반
FROM python:3.10

# 2. 디렉토리 설정
WORKDIR /app

# 3. 필수 패키지 설치
RUN apt update && apt install -y curl gnupg
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt install -y nodejs && npm install -g pm2

# 4. Python 패키지 캐싱 최적화 (불필요한 재설치 방지)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. 애플리케이션 코드 복사
COPY . .

# 6. FastAPI 서버 실행 
CMD ["pm2-runtime", "start", "uvicorn", "--interpreter", "python3", "--", "main:app", "--host", "0.0.0.0", "--port", "8501"]