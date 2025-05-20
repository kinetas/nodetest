FROM node:18

WORKDIR /app

# 소스 복사
COPY package*.json ./

# 종속성 설치
RUN npm install

# pm2 전역 설치
RUN npm install -g pm2

# PM2로 gateway.js 실행
CMD ["pm2-runtime", "gateway.js"]
