import os

SECRET_KEY = os.getenv("SECRET_KEY", "fallback_key_for_dev")
ALGORITHM = os.getenv("ALGORITHM", "HS256")

def get_config():
    return {
        "wsUrl": "wss://27.113.11.48:8500/ws",
        "turn": {
            "urls": ["turn:27.113.11.48:3478?transport=udp"],
            "username": "gogi",
            "credential": "gogi0529"
        }
    }