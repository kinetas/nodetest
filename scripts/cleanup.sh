#!/bin/bash
# ���� ���� ����
# rm -rf /home/ubuntu/nodetest/*
if [ -d "/home/ubuntu/nodetest/" ]; then
  find /home/ubuntu/nodetest/ -mindepth 1 ! -name "firebase-adminsdk.json" -exec rm -rf {} + 2>/dev/null
else
  echo "Directory /home/ubuntu/nodetest/ does not exist. Skipping cleanup."
fi