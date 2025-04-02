from fastapi import FastAPI
from fastapi.responses import FileResponse  # FileResponse 임포트 추가
from fastapi.staticfiles import StaticFiles
from typing import List
import json

app = FastAPI()

# WebSocket 연결 저장소
active_connections: List[WebSocket] = []

# WebSocket 엔드포인트
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    active_connections.append(websocket)
    try:
        while True:
            message = await websocket.receive_text()
            data = json.loads(message)

            # Offer, Answer, ICE Candidate 전송
            for connection in active_connections:
                if connection != websocket:
                    await connection.send_text(json.dumps(data))
    except Exception:
        active_connections.remove(websocket)

# 정적 파일 static 폴더 경로 설정
app.mount("/", StaticFiles(directory="static", html=True), name="static")

# 루트 경로에서 index.html 파일 서빙
@app.get("/")
async def serve_index():
    return FileResponse("static/index.html")