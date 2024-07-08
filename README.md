# E-commerce Website

这是一个基于 Docker 的电子商务网站开发环境。

## 要求

- Docker
- Docker Compose

## 设置

1. 克隆此仓库
2. 在项目根目录运行 `docker-compose up --build`
3. 访问以下地址：
   - 前端：http://localhost
   - 后端（Strapi 管理面板）：http://localhost/admin
   - Adminer（数据库管理）：http://localhost:8080

## 开发

- 前端代码位于 `./frontend` 目录
- 后端代码位于 `./backend` 目录
- 对代码的修改会自动重新加载

## 测试

- 前端测试：在 `frontend` 目录中运行 `npm test`
- 后端测试：在 `backend` 目录中运行 `npm test`

## 注意事项

- 数据库数据持久化在 Docker 卷 `pgdata` 中
- Redis 数据持久化在 Docker 卷 `redisdata` 中
- 环境变量应该设置在 `.env` 文件中（未被 Git 跟踪）

## 常见问题

如果遇到权限问题，尝试在终端中运行：
```
chmod -R 777 ./frontend ./backend
```

如果遇到端口冲突，请修改 `docker-compose.yml` 文件中的端口映射。

## 本地测试

要在本地运行测试，请执行以下命令：

```
./test.sh
```

这将运行前端和后端测试，构建 Docker 镜像，启动服务，检查服务是否正常运行，然后关闭服务。
