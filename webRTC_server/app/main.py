# from fastapi import FastAPI, WebSocket,  WebSocketDisconnect
# from fastapi.responses import FileResponse  # FileResponse 임포트 추가
# from fastapi.staticfiles import StaticFiles
# from typing import List
# import json
# import uvicorn

# app = FastAPI()

# app = FastAPI()
# active_users = {}

# @app.websocket("/ws")
# async def websocket_endpoint(websocket: WebSocket):
#     await websocket.accept()
#     user_id = None

#     try:
#         while True:
#             message = await websocket.receive_text()
#             data = json.loads(message)
#             msg_type = data.get("type")

#             if msg_type == "join":
#                 user_id = data["userId"]
#                 active_users[user_id] = websocket
#                 print(f"User joined: {user_id}")
#                 await broadcast_user_list()

#             elif msg_type in ("offer", "answer", "candidate"):
#                 target_id = data.get("to")
#                 if target_id in active_users:
#                     try:
#                         await active_users[target_id].send_text(json.dumps(data))
#                     except Exception as e:
#                         print(f"Send failed to {target_id}: {e}")
#                         del active_users[target_id]
#                         await broadcast_user_list()
#                 else:
#                     print(f"Target {target_id} not connected.")

#     except WebSocketDisconnect:
#         print(f"Disconnected: {user_id}")
#         if user_id and user_id in active_users:
#             del active_users[user_id]
#             await broadcast_user_list()

#     except Exception as e:
#         print(f"Error: {e}")
#         if user_id and user_id in active_users:
#             del active_users[user_id]
#             await broadcast_user_list()

# async def broadcast_user_list():
#     user_list = list(active_users.keys())
#     for ws in active_users.values():
#         try:
#             await ws.send_text(json.dumps({
#                 "type": "user-list",
#                 "users": user_list
#             }))
#         except:
#             continue
# # 정적 파일 static 폴더 경로 설정
# app.mount("/", StaticFiles(directory="static", html=True), name="static")

# # 루트 경로에서 index.html 파일 서빙
# @app.get("/")
# async def serve_index():
#     return FileResponse("static/index.html")

# if __name__ == "__main__":
#     uvicorn.run("main:app", host="0.0.0.0", port=8500, 
#                 ssl_keyfile="/docker/WEBRTC_SERVER/SECRETE/cert.key", 
#                 ssl_certfile="/docker/WEBRTC_SERVER/SECRETE/cert.crt")
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from app.signaling import signaling_router
from app.config import get_config
from fastapi import Request

app = FastAPI()

# signaling WebSocket 연결
app.include_router(signaling_router)

# 정적 파일 제공
app.mount("/static", StaticFiles(directory="static", html=True), name="static")

@app.get("/")
async def root():
    return FileResponse("static/index.html")

@app.get("/config")
async def config():
    return get_config()

@app.post("/report-fall")
async def report_fall(request: Request):
    data = await request.json()
    user_id = data.get("userId")
    timestamp = data.get("timestamp")
    print(f"🛑 [낙상 감지] 사용자: {user_id}, 시간: {timestamp}")
    return {"message": "Fall report received"}