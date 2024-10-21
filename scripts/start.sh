#!/bin/bash

# Node.js 애플리케이션 시작
cd /home/ubuntu/nodetest  # 애플리케이션 디렉토리로 이동
sudo pm2 start node --name node --interpreter=/usr/bin/node -- /home/ubuntu/nodetest/node.js
pm2 list
