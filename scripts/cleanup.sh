#!/bin/bash
# ���� ���� ����
# rm -rf /home/ubuntu/nodetest/*
find /home/ubuntu/nodetest/ -mindepth 1 ! -name "firebase-adminsdk.json" -exec rm -rf {} +