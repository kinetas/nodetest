# # rag_server/Dockerfile
# FROM python:3.10

# WORKDIR /app

# # pm2 설치용 Node 설치
# RUN apt update && apt install -y curl gnupg
# RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
# RUN apt install -y nodejs
# RUN npm install -g pm2

# # ✅ 크롬 및 크롤링에 필요한 시스템 패키지 추가
# RUN apt-get update && apt-get install -y \
#     wget gnupg2 unzip fonts-liberation libappindicator3-1 libasound2 libatk-bridge2.0-0 \
#     libatk1.0-0 libcups2 libdbus-1-3 libgdk-pixbuf2.0-0 libnspr4 libnss3 libx11-xcb1 libxcomposite1 \
#     libxdamage1 libxrandr2 xdg-utils libu2f-udev libvulkan1 libxss1 libgbm1 libgtk-3-0 \
#     && rm -rf /var/lib/apt/lists/*

# # ✅ 크롬 설치
# RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
#     echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
#     > /etc/apt/sources.list.d/google-chrome.list && \
#     apt-get update && \
#     apt-get install -y google-chrome-stable && \
#     rm -rf /var/lib/apt/lists/*

# COPY requirements.txt .
# RUN pip install --no-cache-dir -r requirements.txt

# COPY . .

# # pm2로 uvicorn 실행 (FastAPI 서버 실행)
# # CMD ["pm2-runtime", "start", "main.py", "--interpreter", "python3", "--", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
# CMD ["pm2-runtime", "start", "uvicorn", "--interpreter", "python3", "--", "main:app", "--host", "0.0.0.0", "--port", "8000"]

FROM python:3.10

# 크롬과 관련된 종속성 설치
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    curl \
    unzip \
    fonts-nanum \
    chromium \
    chromium-driver

# 최신 chromedriver 설치
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    apt-get install -y chromium-driver

ENV CHROME_BIN=/usr/bin/chromium
ENV PATH="${PATH}:/usr/lib/chromium"

# Node.js 설치 (pm2용)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pm2

# 작업 디렉토리 설정
WORKDIR /app
COPY requirements.txt . 
RUN pip install --no-cache-dir -r requirements.txt 
COPY . .
# FastAPI 실행
# CMD ["pm2-runtime", "start", "uvicorn", "--interpreter", "python3", "--", "main:app", "--host", "0.0.0.0", "--port", "8000"]

# PM2 프로세스 설정 파일 복사
COPY ecosystem.config.js .

# 포트 둘 다 expose (선택)
EXPOSE 8000
EXPOSE 8001

CMD ["pm2-runtime", "ecosystem.config.js"]