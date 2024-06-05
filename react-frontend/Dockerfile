# 使用官方 Node.js 16 镜像作为基础镜像
FROM node:16

# 创建应用目录
WORKDIR /usr/src/app

# 安装应用依赖
COPY package.json ./
COPY package-lock.json ./
RUN npm install

# 复制应用源代码
COPY . .

# 构建应用
RUN npm run build

# 暴露应用运行的端口
EXPOSE 3001

# 启动应用
CMD ["npm", "start"]

