#!/bin/bash
# ���� ���� ����
# rm -rf /home/ubuntu/nodetest/*
echo "Starting cleanup script..."

if [ -d "/home/ubuntu/nodetest/" ]; then
  echo "Directory exists. Starting cleanup..."
  find /home/ubuntu/nodetest/ -mindepth 1 ! -name "firebase-adminsdk.json" ! -name ".env" -exec rm -rf {} + 2>/dev/null
  echo "Cleanup completed."
else
  echo "Directory /home/ubuntu/nodetest/ does not exist. Skipping cleanup."
fi