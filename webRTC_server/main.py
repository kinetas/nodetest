from fastapi import FastAPI, WebSocket
from fastapi.staticfiles import StaticFiles
from fastapi.responses import Response
from typing import List
import json
import os

app = FastAPI()

# WebSocket 연결 저장소 설정
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

# favicon.ico 요청을 처리 (빈 응답 반환)
@app.get("/favicon.ico")
async def favicon():
    return Response(status_code=204)  # No Content (빈 응답)