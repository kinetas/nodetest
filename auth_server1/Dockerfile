# ✅ Dockerfile (auth_server 용)
FROM node:18

WORKDIR /app
COPY package.json .



RUN npm install
COPY . .
CMD ["node", "app.js"]