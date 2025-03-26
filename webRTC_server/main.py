from fastapi import FastAPI, WebSocket
from typing import List
import json

app = FastAPI()

active_connections: List[WebSocket] = []

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    active_connections.append(websocket)
    try:
        while True:
            message = await websocket.receive_text()
            data = json.loads(message)

            # Offer, Answer, Candidate 처리
            for connection in active_connections:
                if connection != websocket:
                    await connection.send_text(json.dumps(data))
    except Exception:
        active_connections.remove(websocket)