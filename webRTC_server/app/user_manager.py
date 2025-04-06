from fastapi import WebSocket

active_users = {}

def disconnect_user(websocket: WebSocket):
    disconnected_user = None
    for user_id, ws in list(active_users.items()):
        if ws == websocket:
            disconnected_user = user_id
            break
    if disconnected_user:
        del active_users[disconnected_user]
        print(f"사용자 {disconnected_user} 연결 해제")