#!/bin/bash
#
# OKX Trading System - 完整备份脚本
# 包含：代码、配置、数据、依赖信息
# 目标：/tmp/okx_trading_backup_YYYYMMDD.tar.gz
#

set -e

# 获取今天日期
BACKUP_DATE=$(date +%Y%m%d)
BACKUP_NAME="okx_trading_backup_${BACKUP_DATE}"
BACKUP_DIR="/tmp/${BACKUP_NAME}"
BACKUP_FILE="/tmp/${BACKUP_NAME}.tar.gz"

echo "================================================================================"
echo "🚀 OKX Trading System - 完整备份"
echo "================================================================================"
echo "备份日期: ${BACKUP_DATE}"
echo "备份目录: ${BACKUP_DIR}"
echo "备份文件: ${BACKUP_FILE}"
echo "================================================================================"

# 清理旧的临时目录
if [ -d "${BACKUP_DIR}" ]; then
    echo "🗑️  清理旧的临时目录..."
    rm -rf "${BACKUP_DIR}"
fi

# 创建备份目录结构
echo ""
echo "📁 创建备份目录结构..."
mkdir -p "${BACKUP_DIR}"
mkdir -p "${BACKUP_DIR}/webapp"
mkdir -p "${BACKUP_DIR}/system_config"
mkdir -p "${BACKUP_DIR}/deployment_docs"

# 1. 备份核心代码
echo ""
echo "📦 备份核心代码..."
cd /home/user/webapp

# 备份主应用
cp app.py "${BACKUP_DIR}/webapp/" 2>/dev/null || echo "  ⚠️ app.py 不存在"

# 备份核心目录
for dir in source_code panic_paged_v2 panic_v3 major-events-system scripts coin_tracker tools; do
    if [ -d "$dir" ]; then
        echo "  ✅ 备份 $dir/"
        cp -r "$dir" "${BACKUP_DIR}/webapp/"
    else
        echo "  ⚠️  $dir/ 不存在"
    fi
done

# 2. 备份前端代码
echo ""
echo "🎨 备份前端代码..."
for dir in templates static public; do
    if [ -d "$dir" ]; then
        echo "  ✅ 备份 $dir/"
        cp -r "$dir" "${BACKUP_DIR}/webapp/"
    else
        echo "  ⚠️  $dir/ 不存在"
    fi
done

# 3. 备份配置文件
echo ""
echo "⚙️  备份配置文件..."
if [ -d "config" ]; then
    echo "  ✅ 备份 config/"
    cp -r config "${BACKUP_DIR}/webapp/"
fi

for file in package.json package-lock.json requirements.txt ecosystem.config.js .env; do
    if [ -f "$file" ]; then
        echo "  ✅ 备份 $file"
        cp "$file" "${BACKUP_DIR}/webapp/"
    else
        echo "  ⚠️  $file 不存在"
    fi
done

# 4. 备份数据文件（完整数据）
echo ""
echo "💾 备份数据文件（完整数据）..."
if [ -d "data" ]; then
    echo "  ✅ 备份 data/ (这可能需要一些时间...)"
    cp -r data "${BACKUP_DIR}/webapp/"
else
    echo "  ⚠️  data/ 不存在"
fi

if [ -d "db" ]; then
    echo "  ✅ 备份 db/"
    cp -r db "${BACKUP_DIR}/webapp/"
fi

# 5. 备份文档
echo ""
echo "📚 备份文档..."
cp *.md "${BACKUP_DIR}/webapp/" 2>/dev/null || echo "  ⚠️  没有找到 Markdown 文档"

# 6. 导出系统依赖信息
echo ""
echo "📋 导出系统依赖信息..."

# Python依赖
echo "  • 导出 Python 依赖..."
pip3 list --format=freeze > "${BACKUP_DIR}/system_config/python_packages.txt" 2>/dev/null || echo "    ⚠️ pip3 不可用"

# Node.js依赖（仅记录package.json，不备份node_modules）
if [ -f "package.json" ]; then
    echo "  • 记录 Node.js 依赖配置..."
    cp package.json "${BACKUP_DIR}/system_config/"
    cp package-lock.json "${BACKUP_DIR}/system_config/" 2>/dev/null || true
fi

# PM2进程列表
echo "  • 导出 PM2 进程列表..."
pm2 list > "${BACKUP_DIR}/system_config/pm2_processes.txt" 2>/dev/null || echo "    ⚠️ PM2 不可用"
pm2 save 2>/dev/null || true
if [ -d "$HOME/.pm2" ]; then
    cp "$HOME/.pm2/dump.pm2" "${BACKUP_DIR}/system_config/" 2>/dev/null || true
fi

# 系统包信息
echo "  • 记录系统包信息..."
dpkg -l > "${BACKUP_DIR}/system_config/apt_packages.txt" 2>/dev/null || echo "    ⚠️ dpkg 不可用"

# 7. 生成备份清单
echo ""
echo "📝 生成备份清单..."
cat > "${BACKUP_DIR}/BACKUP_MANIFEST.txt" << 'MANIFEST'
================================================================================
OKX Trading System - 完整备份清单
================================================================================

备份日期: BACKUP_DATE_PLACEHOLDER
备份版本: v3.15.1-FULL-BACKUP

===============================================================================
一、备份内容
================================================================================

1. 核心代码
   - app.py                        主Flask应用
   - source_code/                  Python API文件
   - panic_paged_v2/               Panic Paged V2系统
   - panic_v3/                     Panic V3系统
   - major-events-system/          重大事件系统
   - scripts/                      监控和工具脚本
   - coin_tracker/                 币种追踪模块
   - tools/                        工具模块

2. 前端代码
   - templates/                    HTML模板
   - static/                       静态资源
   - public/                       公共资源

3. 配置文件
   - config/                       系统配置目录
   - package.json                  Node.js依赖配置
   - package-lock.json             Node.js依赖锁定
   - requirements.txt              Python依赖
   - ecosystem.config.js           PM2配置

4. 数据文件（完整数据）
   - data/                         所有数据文件（JSONL等）
   - db/                           数据库文件

5. 文档
   - *.md                          所有Markdown文档

6. 系统配置
   - python_packages.txt           Python包列表
   - apt_packages.txt              系统包列表
   - pm2_processes.txt             PM2进程列表
   - dump.pm2                      PM2进程配置

================================================================================
二、未备份内容（可忽略）
================================================================================

- logs/                            日志文件（可重新生成）
- node_modules/                    Node.js依赖（可重新安装）
- backups/                         旧备份
- __pycache__/                     Python缓存
- .git/                            Git仓库（可从GitHub恢复）

================================================================================
三、备份统计
================================================================================

MANIFEST

# 替换日期占位符
sed -i "s/BACKUP_DATE_PLACEHOLDER/${BACKUP_DATE}/g" "${BACKUP_DIR}/BACKUP_MANIFEST.txt"

# 计算备份大小
echo "正在计算备份大小..." >> "${BACKUP_DIR}/BACKUP_MANIFEST.txt"
du -sh "${BACKUP_DIR}/webapp" 2>/dev/null >> "${BACKUP_DIR}/BACKUP_MANIFEST.txt" || true
find "${BACKUP_DIR}/webapp" -type f 2>/dev/null | wc -l >> "${BACKUP_DIR}/BACKUP_MANIFEST.txt" || true

# 8. 创建压缩包
echo ""
echo "🗜️  创建压缩包..."
cd /tmp
tar czf "${BACKUP_FILE}" "${BACKUP_NAME}/" 2>/dev/null

# 清理临时目录
echo ""
echo "🧹 清理临时目录..."
rm -rf "${BACKUP_DIR}"

# 9. 显示结果
echo ""
echo "================================================================================"
echo "✅ 备份完成！"
echo "================================================================================"
echo "备份文件: ${BACKUP_FILE}"
echo "文件大小: $(du -h "${BACKUP_FILE}" | cut -f1)"
echo ""
echo "📥 下载备份："
echo "   scp user@server:${BACKUP_FILE} ."
echo ""
echo "📦 解压备份："
echo "   tar xzf ${BACKUP_NAME}.tar.gz"
echo "================================================================================"

