# ✅ Dockerfile (auth_server 용)
FROM node:18

WORKDIR /app

# package.json 복사 후 의존성 설치
COPY package.json ./
RUN npm install

# pm2 전역 설치
RUN npm install -g pm2

# 소스 전체 복사
COPY . .

# pm2로 앱 실행
CMD ["pm2-runtime", "start", "app.js"]