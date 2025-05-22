# Node.js 베이스 이미지
FROM node:18

# PM2 글로벌 설치
RUN npm install -g pm2

# 앱 디렉토리 설정
WORKDIR /app

# 의존성 설치
COPY package*.json ./
RUN npm install

# 소스 복사
COPY . .

# PM2로 앱 실행
CMD ["pm2-runtime", "index.js"]

# WebSocket 포트
EXPOSE 3005
