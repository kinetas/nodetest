#!/bin/bash
# ���� ���� ����
# rm -rf /home/ubuntu/nodetest/*
if [ -d "/home/ubuntu/nodetest/" ]; then
  # .env 및 firebase-adminsdk.json은 유지, 하지만 나중에 업데이트될 경우 덮어쓰기
  find /home/ubuntu/nodetest/ -mindepth 1 ! -name "firebase-adminsdk.json" ! -name ".env" -exec rm -rf {} + 2>/dev/null
else
  echo "Directory /home/ubuntu/nodetest/ does not exist. Skipping cleanup."
fi