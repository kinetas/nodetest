from fastapi import WebSocket, WebSocketDisconnect, APIRouter
import json
from user_manager import active_users
from config import SECRET_KEY, ALGORITHM
from jose import jwt, JWTError

signaling_router = APIRouter()

def verify_token(token: str, user_id: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload.get("userId") == user_id
    except JWTError:
        return False

@signaling_router.websocket("/ws")
async def signaling(websocket: WebSocket):
    await websocket.accept()
    user_id = None

    try:
        while True:
            msg = await websocket.receive_text()
            data = json.loads(msg)
            msg_type = data.get("type")

            if msg_type == "join":
                user_id = data.get("userId")
                token = data.get("token")
                if not verify_token(token, user_id):
                    await websocket.close(code=4001)
                    return
                active_users[user_id] = websocket
                await broadcast_user_list()

            elif msg_type in ("offer", "answer", "candidate"):
                to_id = data.get("to")
                if to_id in active_users:
                    await active_users[to_id].send_text(json.dumps(data))

    except WebSocketDisconnect:
        if user_id and user_id in active_users:
            del active_users[user_id]
            await broadcast_user_list()

async def broadcast_user_list():
    user_list = list(active_users.keys())
    for ws in active_users.values():
        try:
            await ws.send_text(json.dumps({
                "type": "user-list",
                "users": user_list
            }))
        except:
            continue