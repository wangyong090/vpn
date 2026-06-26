#!/usr/bin/env bash
# BPB Panel 配置指南邮件一键发送脚本
# 使用 agently-cli 发送邮件到 QQ 邮箱
#
# 使用方法：
#   1. 确保已安装并登录 agently-cli
#      npm install -g @tencent-qqmail/agently-cli
#      agently-cli auth login
#   2. 运行脚本：bash send_bpb_guide.sh
#

set -euo pipefail

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 配置
RECEIVER="19448063@qq.com"
SUBJECT="BPB Worker Panel 完整部署配置指南"
ATTACHMENT="BPB_Panel_部署配置指南.md"

BODY="您好！

附件是 BPB Worker Panel 的完整部署与配置指南。

文档包含以下内容：
- 项目概述
- 部署步骤（手动部署 / Wrangler CLI 部署）
- KV 存储配置（关键：binding 必须为 kv）
- 环境变量配置
- 验证与首次使用
- 高级配置
- 常见问题解答
- 配置信息汇总表

请妥善保管您的 UUID 和密码等配置信息。

祝使用愉快！

---
本文档由自动化脚本生成
BPB Panel v4.1.3"

echo "============================================"
echo "  BPB Panel 配置指南 - 邮件发送"
echo "============================================"
echo ""

# 检查 agently-cli
if ! command -v agently-cli &> /dev/null; then
    echo -e "${RED}[错误] 未找到 agently-cli${NC}"
    echo "请先安装：npm install -g @tencent-qqmail/agently-cli"
    exit 1
fi
echo -e "${GREEN}[✓]${NC} agently-cli 已安装"

# 检查登录状态
echo "检查登录状态..."
LOGIN_STATUS=$(agently-cli auth status 2>&1)
if echo "$LOGIN_STATUS" | grep -q '"logged_in": true'; then
    echo -e "${GREEN}[✓]${NC} 已登录 QQ 邮箱"
    USER_INFO=$(echo "$LOGIN_STATUS" | grep -o '"email":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "  邮箱: $USER_INFO"
else
    echo -e "${RED}[错误] 未登录${NC}"
    echo "请先运行：agently-cli auth login"
    exit 1
fi
echo ""

# 检查附件
if [ ! -f "$ATTACHMENT" ]; then
    echo -e "${RED}[错误] 附件文件不存在: $ATTACHMENT${NC}"
    echo "请确保脚本与 $ATTACHMENT 在同一目录"
    exit 1
fi
ATTACH_SIZE=$(wc -c < "$ATTACHMENT" | tr -d ' ')
echo -e "${GREEN}[✓]${NC} 附件就绪: $ATTACHMENT (${ATTACH_SIZE} 字节)"
echo ""

# 显示收件人
echo -e "${YELLOW}收件人:${NC} $RECEIVER"
echo -e "${YELLOW}主题:${NC} $SUBJECT"
echo -e "${YELLOW}附件:${NC} $ATTACHMENT"
echo ""

# 第一步：上传附件
echo "============================================"
echo "  步骤 1/3: 上传附件"
echo "============================================"
UPLOAD_RESULT=$(agently-cli attachment +upload --file "$ATTACHMENT" 2>&1)
echo "$UPLOAD_RESULT"

if ! echo "$UPLOAD_RESULT" | grep -q '"ok": true'; then
    echo -e "${RED}[错误] 附件上传失败${NC}"
    exit 1
fi
echo -e "${GREEN}[✓]${NC} 附件上传成功"
echo ""

# 第二步：发送邮件（获取确认 token）
echo "============================================"
echo "  步骤 2/3: 请求发送邮件"
echo "============================================"
SEND_RESULT=$(agently-cli message +send \
    --to "$RECEIVER" \
    --subject "$SUBJECT" \
    --body "$BODY" 2>&1)
echo "$SEND_RESULT"

if ! echo "$SEND_RESULT" | grep -q '"ok": true'; then
    echo -e "${RED}[错误] 邮件发送请求失败${NC}"
    exit 1
fi

# 提取 confirmation_token
CONFIRM_TOKEN=$(echo "$SEND_RESULT" | grep -o '"confirmation_token":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$CONFIRM_TOKEN" ]; then
    echo -e "${YELLOW}[提示] 未获取到确认 token，可能已直接发送${NC}"
    echo -e "${GREEN}[✓]${NC} 邮件可能已发送"
else
    echo -e "${GREEN}[✓]${NC} 已获取确认 Token"
    echo "  Token: ${CONFIRM_TOKEN:0:20}..."
    echo ""

    # 第三步：确认发送
    echo "============================================"
    echo "  步骤 3/3: 确认发送"
    echo "============================================"
    CONFIRM_RESULT=$(agently-cli message +send \
        --to "$RECEIVER" \
        --subject "$SUBJECT" \
        --body "$BODY" \
        --confirmation-token "$CONFIRM_TOKEN" 2>&1)
    echo "$CONFIRM_RESULT"

    if echo "$CONFIRM_RESULT" | grep -q '"ok": true'; then
        echo -e "${GREEN}[✓]${NC} 邮件确认发送成功！"
    else
        echo -e "${RED}[错误] 邮件确认发送失败${NC}"
        exit 1
    fi
fi

echo ""
echo "============================================"
echo -e "  ${GREEN}发送完成！${NC}"
echo "============================================"
echo ""
echo "请查收邮箱: $RECEIVER"
echo "（如果没收到，检查一下垃圾箱）"
