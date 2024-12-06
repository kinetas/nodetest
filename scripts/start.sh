#!/bin/bash

# JSON 파일에서 \n을 실제 줄바꿈으로 변환
# JSON_FILE="/home/ubuntu/nodetest/firebase-adminsdk.json"

# if [ -f "$JSON_FILE" ]; then
#   sed -i 's/\\n/\n/g' "$JSON_FILE"
#   echo "Updated JSON file with line breaks."
# else
#   echo "JSON file not found: $JSON_FILE"
# fi

# Node.js 애플리케이션 시작
cd /home/ubuntu/nodetest  # 애플리케이션 디렉토리로 이동
pm2 start app.js
pm2 start socketServer.js
pm2 save
