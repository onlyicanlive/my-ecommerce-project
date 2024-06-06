# 使用官方 Node.js 18 镜像作为基础镜像
FROM node:18

# 创建应用目录
WORKDIR /usr/src/app

# 复制依赖文件
COPY package.json ./
COPY yarn.lock ./
COPY .yarnrc.yml ./

# 安装应用依赖
RUN yarn install

# 复制应用源代码
COPY . .

# 构建应用
RUN yarn build

# 暴露应用运行的端口
EXPOSE 3001

# 启动应用
CMD ["yarn", "start"]

