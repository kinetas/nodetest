#!/bin/bash

# Node.js ���ø����̼� ����
cd /home/ubuntu/nodetest  # ���ø����̼� ���丮�� �̵�
pm2 start app.js
pm2 start socketServer.js
