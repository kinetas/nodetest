#!/bin/bash

# Node.js ���ø����̼� ����
cd /home/ubuntu/nodetest  # ���ø����̼� ���丮�� �̵�
sudo pm2 start node --name node --interpreter=/usr/bin/node -- /home/ubuntu/nodetest/node.js
pm2 list
