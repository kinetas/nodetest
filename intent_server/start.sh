#!/bin/bash

# ✅ intent_model 디렉토리가 마운트되었는지 확인
echo "⏳ Waiting for /app/intent_model to be mounted..."
for i in {1..30}; do
  if [ -d "/app/intent_model" ]; then
    echo "✅ /app/intent_model exists"
    break
  fi
  echo "🔄 Waiting... ($i)"
  sleep 1
done

# ✅ 모델이 없을 경우 학습 수행
if [ ! -f "/app/intent_model/config.json" ]; then
  echo "🚀 No model found. Training now..."
  python3 fine_tuned_intent_model.py
else
  echo "✅ Pretrained model found. Skipping training."
fi

# ✅ PM2로 FastAPI 실행
pm2-runtime uvicorn --intent_classifier:app --host 0.0.0.0 --port 8002

