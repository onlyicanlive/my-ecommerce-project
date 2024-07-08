#!/bin/bash

# 创建 docker-compose.yml 文件
cat << EOF > docker-compose.yml
version: '3.8'

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3001:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - REACT_APP_API_URL=http://localhost:4000
    depends_on:
      - backend

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "4000:1337"
    volumes:
      - ./backend:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - DATABASE_CLIENT=postgres
      - DATABASE_HOST=db
      - DATABASE_PORT=5432
      - DATABASE_NAME=strapi
      - DATABASE_USERNAME=strapi
      - DATABASE_PASSWORD=strapi
      - DATABASE_SSL=false
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      - db
      - redis

  db:
    image: postgres:13
    ports:
      - "5433:5432"
    environment:
      POSTGRES_DB: strapi
      POSTGRES_USER: strapi
      POSTGRES_PASSWORD: strapi
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    volumes:
      - redisdata:/data

  adminer:
    image: adminer
    ports:
      - "8080:8080"
    depends_on:
      - db

  nginx:
    build:
      context: ./nginx
      dockerfile: Dockerfile
    ports:
      - "80:80"
    depends_on:
      - frontend
      - backend

volumes:
  pgdata:
  redisdata:
EOF

# 创建前端项目
mkdir frontend && cd frontend
npx create-react-app .
npm install axios react-intl redux react-redux @reduxjs/toolkit styled-components

# 创建前端 Dockerfile
cat << EOF > Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
EOF

# 创建前端测试脚本
mkdir -p src/__tests__
cat << EOF > src/__tests__/App.test.js
import React from 'react';
import { render, screen } from '@testing-library/react';
import App from '../App';

test('renders learn react link', () => {
  render(<App />);
  const linkElement = screen.getByText(/learn react/i);
  expect(linkElement).toBeInTheDocument();
});
EOF

cd ..

# 创建后端项目
mkdir backend && cd backend
npx create-strapi-app@latest . --quickstart --no-run

# 安装额外的依赖
npm install pg redis

# 创建后端 Dockerfile
cat << EOF > Dockerfile
FROM node:18-alpine

WORKDIR /app

RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev > /dev/null 2>&1

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

EXPOSE 1337

CMD ["npm", "run", "develop"]
EOF

# 创建数据库配置文件
mkdir -p config
cat << EOF > config/database.js
module.exports = ({ env }) => ({
  connection: {
    client: 'postgres',
    connection: {
      host: env('DATABASE_HOST', 'db'),
      port: env.int('DATABASE_PORT', 5432),
      database: env('DATABASE_NAME', 'strapi'),
      user: env('DATABASE_USERNAME', 'strapi'),
      password: env('DATABASE_PASSWORD', 'strapi'),
      ssl: env.bool('DATABASE_SSL', false),
    },
    debug: false,
  },
});
EOF

# 创建 Redis 配置文件
cat << EOF > config/redis.js
module.exports = ({ env }) => ({
  redis: {
    config: {
      host: env('REDIS_HOST'),
      port: env.int('REDIS_PORT'),
    },
  },
});
EOF

cd ..

# 创建 Nginx 配置
mkdir nginx && cd nginx
cat << EOF > nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream frontend {
        server frontend:3000;
    }

    upstream backend {
        server backend:1337;
    }

    server {
        listen 80;
        server_name localhost;

        location / {
            proxy_pass http://frontend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }

        location /api {
            rewrite ^/api/(.*) /\$1 break;
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }

        location /admin {
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
    }
}
EOF

# 创建 Nginx Dockerfile
cat << EOF > Dockerfile
FROM nginx:alpine

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
EOF

cd ..

# 创建 .gitignore 文件
cat << EOF > .gitignore
# 依赖
node_modules

# 构建输出
build
dist

# 环境文件
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# 日志
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# 编辑器配置
.vscode
.idea

# 操作系统文件
.DS_Store
Thumbs.db

# Strapi
.strapi-updater.json
.cache
EOF

# 创建 README.md 文件
cat << EOF > README.md
# E-commerce Website

这是一个基于 Docker 的电子商务网站开发环境。

## 要求

- Docker
- Docker Compose

## 设置

1. 克隆此仓库
2. 在项目根目录运行 \`docker-compose up --build\`
3. 访问以下地址：
   - 前端：http://localhost
   - 后端（Strapi 管理面板）：http://localhost/admin
   - Adminer（数据库管理）：http://localhost:8080

## 开发

- 前端代码位于 \`./frontend\` 目录
- 后端代码位于 \`./backend\` 目录
- 对代码的修改会自动重新加载

## 测试

- 前端测试：在 \`frontend\` 目录中运行 \`npm test\`
- 后端测试：在 \`backend\` 目录中运行 \`npm test\`

## 注意事项

- 数据库数据持久化在 Docker 卷 \`pgdata\` 中
- Redis 数据持久化在 Docker 卷 \`redisdata\` 中
- 环境变量应该设置在 \`.env\` 文件中（未被 Git 跟踪）

## 常见问题

如果遇到权限问题，尝试在终端中运行：
\`\`\`
chmod -R 777 ./frontend ./backend
\`\`\`

如果遇到端口冲突，请修改 \`docker-compose.yml\` 文件中的端口映射。
EOF


# 更新 GitHub Actions 工作流文件
mkdir -p .github/workflows
cat << EOF > .github/workflows/ci-cd.yml
name: CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Use Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '18'
    - name: Install dependencies
      run: |
        cd frontend && npm ci
        cd ../backend && npm ci
    - name: Run tests
      run: |
        cd frontend && npm test
        cd ../backend && npm test

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - name: Build Docker images
      run: docker-compose build

  # 注释掉部署步骤，因为现在是本地开发阶段
  # deploy:
  #   needs: build
  #   runs-on: ubuntu-latest
  #   if: github.ref == 'refs/heads/main'
  #   steps:
  #   - uses: actions/checkout@v2
  #   - name: Deploy to server
  #     run: echo "部署步骤将在未来实现"

EOF

# 添加本地测试脚本
cat << EOF > test.sh
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
EOF

chmod +x test.sh

# 更新 README.md 文件
cat << EOF >> README.md

## 本地测试

要在本地运行测试，请执行以下命令：

\`\`\`
./test.sh
\`\`\`

这将运行前端和后端测试，构建 Docker 镜像，启动服务，检查服务是否正常运行，然后关闭服务。
EOF

# 初始化 Git 仓库
git init
git add .
git commit -m "Initial commit with full Docker setup and local testing"

echo "开发环境设置完成，并添加了本地测试脚本！"
