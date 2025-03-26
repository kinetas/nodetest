from fastapi import FastAPI, WebSocket
from typing import List

app = FastAPI()

# 현재 연결된 클라이언트 리스트
active_connections: List[WebSocket] = []

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    active_connections.append(websocket)
    try:
        while True:
            data = await websocket.receive_text()
            for connection in active_connections:
                await connection.send_text(data)
    except Exception:
        active_connections.remove(websocket)