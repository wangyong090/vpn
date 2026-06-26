#!/bin/bash
# Cloudflare Workers 部署脚本

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================="
echo -e "  Cloudflare Workers 部署脚本"
echo -e "=========================================${NC}"
echo ""

# 检查必需文件
if [ ! -f "_worker.js" ]; then
    echo -e "${RED}❌ 错误: _worker.js 文件不存在${NC}"
    exit 1
fi

if [ ! -f "wrangler.toml" ]; then
    echo -e "${RED}❌ 错误: wrangler.toml 文件不存在${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 必需文件检查通过${NC}"
echo ""

# 检查 Wrangler 是否安装
if ! command -v wrangler &> /dev/null; then
    echo -e "${YELLOW}⚠️ Wrangler CLI 未安装，正在安装...${NC}"
    npm install -g wrangler
fi

echo -e "${GREEN}✅ Wrangler CLI 已就绪${NC}"
echo ""

# 登录 Cloudflare（如果未登录）
echo -e "${YELLOW}📋 检查 Cloudflare 登录状态...${NC}"
if wrangler whoami &> /dev/null; then
    echo -e "${GREEN}✅ 已登录 Cloudflare${NC}"
    wrangler whoami
else
    echo -e "${YELLOW}⚠️ 需要登录 Cloudflare${NC}"
    echo -e "${YELLOW}运行: wrangler login${NC}"
    echo -e "${YELLOW}然后重新运行此脚本${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}========================================="
echo -e "  部署选项"
echo -e "=========================================${NC}"
echo "1. 部署到生产环境 (wrangler deploy)"
echo "2. 预览模式 (wrangler dev)"
echo "3. 仅验证配置"
echo ""

read -p "请选择操作 [1-3]: " choice

case $choice in
    1)
        echo ""
        echo -e "${GREEN}🚀 开始部署到生产环境...${NC}"
        wrangler deploy
        echo ""
        echo -e "${GREEN}✅ 部署成功！${NC}"
        echo -e "${GREEN}您的 Worker 应该已经在运行了${NC}"
        ;;
    2)
        echo ""
        echo -e "${GREEN}🔧 启动开发模式...${NC}"
        echo -e "${YELLOW}按 Ctrl+C 停止${NC}"
        wrangler dev
        ;;
    3)
        echo ""
        echo -e "${GREEN}🔍 验证配置...${NC}"
        wrangler deploy --dry-run
        echo ""
        echo -e "${GREEN}✅ 配置验证通过${NC}"
        ;;
    *)
        echo -e "${RED}❌ 无效选项${NC}"
        exit 1
        ;;
esac