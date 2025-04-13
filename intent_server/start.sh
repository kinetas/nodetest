#!/bin/bash

# intent_model 폴더가 마운트될 때까지 기다림 (최대 30초)
echo "⏳ Waiting for /app/intent_model to be mounted..."
for i in {1..30}; do
  if [ -f "/app/intent_model/config.json" ]; then
    echo "✅ intent_model detected!"
    break
  fi
  echo "🔄 Still waiting... ($i)"
  sleep 1
done

# PM2로 서버 실행
pm2-runtime uvicorn --intent_classifier:app --host 0.0.0.0 --port 8002
