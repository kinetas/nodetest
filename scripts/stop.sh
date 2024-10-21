#!/bin/bash

# Node.js 애플리케이션 종료
cd /home/ubuntu/nodetest  # 애플리케이션 디렉토리로 이동
pm2 kill
pm2 list