from fastapi import WebSocket, WebSocketDisconnect, APIRouter
import json
from typing import Dict
from app.user_manager import active_users, disconnect_user
from app.config import SECRET_KEY, ALGORITHM
from jose import jwt, JWTError

signaling_router = APIRouter()
#테스트 후 복구

# def verify_token(token: str, user_id: str) -> bool:
#     if not token:
#         print("No token provided")
#         return False
#     try:
#         payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
#         sub = payload.get("sub")
#         if sub != user_id:
#             print(f"Token user_id mismatch: token={sub}, actual={user_id}")
#             return False
#         print(f"Token verified for user_id: {user_id}")
#         return True
#     except JWTError as e:
#         print(f"Invalid token: {e}")
#         return False

def verify_token(token: str, user_id: str) -> bool:
    # ✅ 테스트용: 인증 우회
    print(f"[테스트모드] 토큰 검증 생략 - user_id: {user_id}")
    return True

@signaling_router.websocket("/ws")
async def signaling(websocket: WebSocket):
    await websocket.accept()
    print("🔗 WebSocket connection open")
    user_id = None

    try:
        while True:
            data = await websocket.receive_json()
            msg_type = data.get("type")

            if msg_type == "join":
                user_id = data.get("userId")
                token = data.get("token")

                if not token:
                    print("No token provided")
                    await websocket.close()
                    return

                if not verify_token(token, user_id):
                    await websocket.close()
                    return

                active_users[user_id] = websocket
                print(f"{user_id} joined WebRTC signaling")
                await broadcast_user_list()

            elif msg_type == "offer":
                target_id = data["targetId"]
                if target_id in active_users:
                    await active_users[target_id].send_json(data)

            elif msg_type == "answer":
                target_id = data["targetId"]
                if target_id in active_users:
                    await active_users[target_id].send_json(data)

            elif msg_type == "candidate":
                target_id = data["targetId"]
                if target_id in active_users:
                    await active_users[target_id].send_json(data)

    except WebSocketDisconnect:
        disconnect_user(websocket)
        await broadcast_user_list()
        print("WebSocket disconnected")
    except Exception as e:
        print(f"WebSocket error: {e}")
        disconnect_user(websocket)
        await broadcast_user_list()

async def broadcast_user_list():
    user_list = list(active_users.keys())
    print(f"Broadcasting user list: {user_list}")
    for ws in active_users.values():
        await ws.send_json({"type": "userlist", "users": user_list})