# intent_classifier.py
from fastapi import FastAPI
from pydantic import BaseModel
from transformers import pipeline
import uvicorn

app = FastAPI()

# ✅ 한국어 분류 모델 로딩 (처음엔 조금 느림)
# classifier = pipeline("text-classification", model="monologg/koelectra-small-v3-discriminator")
classifier = pipeline("text-classification", model="./intent_model")

class Query(BaseModel):
    text: str

@app.post("/intent-classify")
async def classify(query: Query):
    result = classifier(query.text)[0]
    return {"intent": result["label"]}  # GENERAL or SPECIFIC

if __name__ == "__main__":
    uvicorn.run("intent_classifier:app", host="0.0.0.0", port=8001, reload=True)