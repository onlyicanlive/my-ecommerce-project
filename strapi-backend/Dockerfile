# 使用官方 Node.js 18 镜像作为基础镜像
FROM node:18

# 创建应用目录
WORKDIR /usr/src/app

# 复制依赖文件
COPY package.json ./
COPY yarn.lock ./
COPY .yarnrc.yml ./

# 安装应用依赖
RUN yarn install --ignore-optional

# 复制应用源代码
COPY . .

# 暴露 Strapi 运行的端口
EXPOSE 1338

# 启动 Strapi 服务器
CMD ["yarn", "develop"]

