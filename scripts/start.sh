#!/bin/bash

# JSON 파일에서 \n을 실제 줄바꿈으로 변환
# JSON_FILE="/home/ubuntu/nodetest/firebase-adminsdk.json"

# if [ -f "$JSON_FILE" ]; then
#   sed -i 's/\\n/\n/g' "$JSON_FILE"
#   echo "Updated JSON file with line breaks."
# else
#   echo "JSON file not found: $JSON_FILE"
# fi

JSON_FILE="/home/ubuntu/nodetest/firebase-adminsdk.json"

# JSON 파일이 존재하는지 확인
if [ -f "$JSON_FILE" ]; then
  # 첫 번째 sed 명령어: 키에 큰따옴표 추가
  sed -i 's/^\(\s*\)\([a-zA-Z_][a-zA-Z_0-9]*\):/\1"\2":/g' "$JSON_FILE"
  # 두 번째 sed 명령어: 값에 큰따옴표 추가, 쉼표는 큰따옴표 밖으로
  sed -i 's/^\(\s*"\?[a-zA-Z_][a-zA-Z_0-9]*"\?\):\s*\(.*[^",]\)\(,\?\)$/\1: "\2"\3/g' "$JSON_FILE"
  echo "Updated JSON file with key and value quotes."
else
  echo "JSON file not found: $JSON_FILE"
fi
# Node.js 애플리케이션 시작
cd /home/ubuntu/nodetest  # 애플리케이션 디렉토리로 이동
pm2 start app.js
pm2 start socketServer.js
pm2 save
