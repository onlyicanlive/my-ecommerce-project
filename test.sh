#!/bin/bash

# 运行前端测试
echo "运行前端测试..."
cd frontend
npm test
cd ..

# 运行后端测试
echo "运行后端测试..."
cd backend
npm test
cd ..

# 构建 Docker 镜像
echo "构建 Docker 镜像..."
docker-compose build

# 启动服务
echo "启动服务..."
docker-compose up -d

# 等待服务启动
echo "等待服务启动..."
sleep 30

# 检查服务是否正常运行
echo "检查服务是否正常运行..."
curl -f http://localhost || exit 1
curl -f http://localhost/admin || exit 1

# 关闭服务
echo "测试完成，关闭服务..."
docker-compose down

echo "本地测试完成！"
