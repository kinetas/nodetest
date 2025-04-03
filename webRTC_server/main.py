from fastapi import FastAPI, WebSocket,  WebSocketDisconnect
from fastapi.responses import FileResponse  # FileResponse 임포트 추가
from fastapi.staticfiles import StaticFiles
from typing import List
import json
import uvicorn

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
            print(f"Received message: {message}")  # 메시지 확인
            data = json.loads(message)

            # Offer, Answer, ICE Candidate 전송
            for connection in active_connections:
                if connection != websocket:
                    print(f"Sending data: {data}")  # 보내는 데이터 확인
                    await connection.send_text(json.dumps(data))
    except WebSocketDisconnect as e:
        print(f"WebSocket disconnected: {e.code}, {e.reason}")  # 연결 종료 이유 로그 출력
        active_connections.remove(websocket)
    except Exception as e:
        print(f"Error in WebSocket connection: {str(e)}")  # 예외 메시지 출력

# 정적 파일 static 폴더 경로 설정
app.mount("/", StaticFiles(directory="static", html=True), name="static")

# 루트 경로에서 index.html 파일 서빙
@app.get("/")
async def serve_index():
    return FileResponse("static/index.html")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8500, 
                ssl_keyfile="/docker/WEBRTC_SERVER/SECRETE/cert.key", 
                ssl_certfile="/docker/WEBRTC_SERVER/SECRETE/cert.crt")