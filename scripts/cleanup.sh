#!/bin/bash
# ���� ���� ����
# rm -rf /home/ubuntu/nodetest/*
if [ -d "/home/ubuntu/nodetest/" ]; then
  # firebase-adminsdk.json과 .env 파일 제외 삭제
  find /home/ubuntu/nodetest/ -mindepth 1 ! -name "firebase-adminsdk.json" ! -name ".env" -exec rm -rf {} + 2>/dev/null
else
  echo "Directory /home/ubuntu/nodetest/ does not exist. Skipping cleanup."
fi