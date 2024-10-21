#!/bin/bash

# Node.js 애플리케이션 시작
cd /home/ubuntu/nodetest  # 애플리케이션 디렉토리로 이동
pm2 start node.js  # 또는 node your-server-file.js
pm2 list
