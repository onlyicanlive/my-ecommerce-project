#!/bin/bash

# 设置错误时退出
set -e

echo "开始 Git 仓库设置和文件添加流程..."

# 检查是否在正确的目录
if [ ! -d "frontend" ] || [ ! -d "backend" ]; then
    echo "错误：请确保您在项目根目录中运行此脚本。"
    exit 1
fi

# 处理嵌套的 Git 仓库
if [ -d "backend/.git" ]; then
    echo "检测到 backend 目录中存在嵌套的 Git 仓库，正在删除..."
    rm -rf backend/.git
    echo "已删除 backend/.git 目录"
fi

# 确保我们在一个 Git 仓库中
if [ ! -d ".git" ]; then
    echo "初始化 Git 仓库..."
    git init
fi

# 添加所有文件
echo "添加所有文件到 Git 仓库..."
git add .

# 检查是否有文件被添加
if git diff --cached --quiet; then
    echo "没有文件被添加，可能所有文件都已经在仓库中了。"
else
    # 提交更改
    echo "提交更改..."
    git commit -m "Initial commit with full project setup"
fi

# 检查远程仓库是否已设置
if ! git remote | grep -q "origin"; then
    echo "请输入您的 GitHub 仓库 URL："
    read repo_url
    git remote add origin $repo_url
fi

# 推送到 GitHub
echo "推送更改到 GitHub..."
git push -u origin main

echo "完成！您的项目已经被成功添加并推送到 GitHub。"

# 显示最终状态
echo "当前 Git 状态："
git status
