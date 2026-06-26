#!/bin/bash
# GitHub Actions 工作流测试脚本

set -euo pipefail

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试计数器
TESTS_PASSED=0
TESTS_FAILED=0

# 确保计数器函数在子 shell 中也能工作
pass_test() { TESTS_PASSED=$((TESTS_PASSED + 1)); }
fail_test() { TESTS_FAILED=$((TESTS_FAILED + 1)); }

# 日志函数
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# 测试函数
test_file() {
    local file=$1
    local description=$2

    if [ -f "$file" ]; then
        log_info "✓ $description: $file 存在"
        pass_test
        return 0
    else
        log_error "✗ $description: $file 不存在"
        fail_test
        return 1
    fi
}

test_yaml_syntax() {
    local file=$1

    if command -v yq &> /dev/null; then
        if yq eval '.' "$file" > /dev/null 2>&1; then
            log_info "✓ YAML 语法正确: $file"
            pass_test
        else
            log_error "✗ YAML 语法错误: $file"
            fail_test
        fi
    else
        log_warn "跳过 YAML 语法检查 (yq 未安装)"
    fi
}

test_shellcheck() {
    local script=$1

    if command -v shellcheck &> /dev/null; then
        if shellcheck "$script"; then
            log_info "✓ ShellCheck 通过: $script"
            pass_test
        else
            log_warn "⚠ ShellCheck 警告: $script (可忽略)"
        fi
    else
        log_warn "跳过 ShellCheck 检查 (shellcheck 未安装)"
    fi
}

echo "========================================="
echo "  GitHub Actions 工作流测试套件"
echo "========================================="
echo ""

# 测试必需文件
log_info "测试 1: 检查必需文件"
test_file ".github/workflows/main.yml" "工作流文件"
test_file "_worker.js" "Worker 脚本"
test_file "version.txt" "版本文件"
echo ""

# 测试 YAML 语法
log_info "测试 2: YAML 语法检查"
if [ -f ".github/workflows/main.yml" ]; then
    test_yaml_syntax ".github/workflows/main.yml"
fi
echo ""

# 提取并测试脚本
log_info "测试 3: Shell 脚本检查"
WORKFLOW_FILE=".github/workflows/main.yml"
if [ -f "$WORKFLOW_FILE" ]; then
    # 提取 run 块中的脚本
    temp_script=$(mktemp)
    sed -n '/run: |/,/^      - name:/p' "$WORKFLOW_FILE" | \
        sed '1d;$d' > "$temp_script"

    if [ -s "$temp_script" ]; then
        test_shellcheck "$temp_script"
    fi
    rm -f "$temp_script"
fi
echo ""

# 测试版本格式
log_info "测试 4: 版本格式检查"
VERSION=$(cat version.txt 2>/dev/null || echo "")
if [[ "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    log_info "✓ 版本格式正确: $VERSION"
    pass_test
else
    log_warn "⚠ 版本格式异常: $VERSION (预期格式: vX.Y.Z)"
fi
echo ""

# 测试 Worker 文件大小
log_info "测试 5: Worker 文件检查"
if [ -f "_worker.js" ]; then
    SIZE=$(wc -c < _worker.js)
    if [ "$SIZE" -gt 0 ]; then
        log_info "✓ Worker 文件大小: $SIZE 字节"
        pass_test
    else
        log_error "✗ Worker 文件为空"
        fail_test
    fi
else
    log_error "✗ Worker 文件不存在"
    fail_test
fi
echo ""

# 测试 GitHub API 连接
log_info "测试 6: GitHub API 连接测试"
API_URL="https://api.github.com/repos/bia-pain-bache/BPB-Worker-Panel/releases"
if curl -s --max-time 10 "$API_URL" > /dev/null 2>&1; then
    log_info "✓ GitHub API 可访问"
    pass_test
else
    log_warn "⚠ GitHub API 连接失败 (可能是网络问题)"
fi
echo ""

# 测试结果汇总
echo "========================================="
echo "  测试结果汇总"
echo "========================================="
echo -e "通过: ${GREEN}$TESTS_PASSED${NC}"
echo -e "失败: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    log_info "所有测试通过! ✓"
    exit 0
else
    log_error "有 $TESTS_FAILED 个测试失败"
    exit 1
fi