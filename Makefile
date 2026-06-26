.PHONY: test validate clean help

# 默认目标
help:
	@echo "BPB Worker Panel 管理命令"
	@echo ""
	@echo "使用方法: make [命令]"
	@echo ""
	@echo "可用命令:"
	@echo "  test      - 运行测试脚本"
	@echo "  validate  - 验证项目文件"
	@echo "  clean     - 清理临时文件"
	@echo "  help      - 显示此帮助信息"

# 运行测试
test:
	@echo "🧪 运行测试..."
	@chmod +x test_workflow.sh
	@./test_workflow.sh

# 验证项目
validate:
	@echo "🔍 验证项目文件..."
	@test -f .github/workflows/main.yml || (echo "❌ main.yml 不存在"; exit 1)
	@test -f _worker.js || (echo "❌ _worker.js 不存在"; exit 1)
	@test -f version.txt || (echo "❌ version.txt 不存在"; exit 1)
	@echo "✅ 所有必需文件验证通过"

# 清理临时文件
clean:
	@echo "🧹 清理临时文件..."
	@rm -f *.zip *.tmp *.log
	@echo "✅ 清理完成"