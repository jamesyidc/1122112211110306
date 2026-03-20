#!/bin/bash
# 完整系统备份脚本 - 使用cp代替rsync
set -e

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="webapp_complete_backup_${BACKUP_DATE}"
BACKUP_DIR="/tmp/${BACKUP_NAME}"
BACKUP_FILE="/tmp/${BACKUP_NAME}.tar.gz"
SOURCE_DIR="/home/user/webapp"

echo "======================================================"
echo "🚀 开始创建完整系统备份"
echo "======================================================"
echo "📅 备份时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "📂 源目录: ${SOURCE_DIR}"
echo "💾 备份目录: ${BACKUP_DIR}"
echo "📦 备份文件: ${BACKUP_FILE}"
echo "======================================================"

# 创建临时备份目录
mkdir -p "${BACKUP_DIR}"

echo ""
echo "📋 备份内容清单："
echo "======================================================"

# 1. Python文件（根目录）
echo "1️⃣  复制根目录Python文件..."
find "${SOURCE_DIR}" -maxdepth 1 -type f -name "*.py" -exec cp {} "${BACKUP_DIR}/" \; 2>/dev/null || true
PY_COUNT=$(find "${SOURCE_DIR}" -maxdepth 1 -type f -name "*.py" 2>/dev/null | wc -l)
echo "   ✅ 根目录Python文件: ${PY_COUNT} 个"

# 2. source_code/ 目录
echo "2️⃣  复制 source_code/ 目录..."
if [ -d "${SOURCE_DIR}/source_code" ]; then
    cp -r "${SOURCE_DIR}/source_code" "${BACKUP_DIR}/"
    SC_COUNT=$(find "${SOURCE_DIR}/source_code" -name "*.py" 2>/dev/null | wc -l)
    echo "   ✅ source_code/: ${SC_COUNT} 个Python文件"
fi

# 3. panic_paged_v2/ 目录
echo "3️⃣  复制 panic_paged_v2/ 目录..."
if [ -d "${SOURCE_DIR}/panic_paged_v2" ]; then
    cp -r "${SOURCE_DIR}/panic_paged_v2" "${BACKUP_DIR}/"
    PP_COUNT=$(find "${SOURCE_DIR}/panic_paged_v2" -type f 2>/dev/null | wc -l)
    echo "   ✅ panic_paged_v2/: ${PP_COUNT} 个文件"
fi

# 4. panic_v3/ 目录
echo "4️⃣  复制 panic_v3/ 目录..."
if [ -d "${SOURCE_DIR}/panic_v3" ]; then
    cp -r "${SOURCE_DIR}/panic_v3" "${BACKUP_DIR}/"
    PV_COUNT=$(find "${SOURCE_DIR}/panic_v3" -type f 2>/dev/null | wc -l)
    echo "   ✅ panic_v3/: ${PV_COUNT} 个文件"
fi

# 5. scripts/ 目录
echo "5️⃣  复制 scripts/ 目录..."
if [ -d "${SOURCE_DIR}/scripts" ]; then
    cp -r "${SOURCE_DIR}/scripts" "${BACKUP_DIR}/"
    SC_COUNT=$(find "${SOURCE_DIR}/scripts" -type f 2>/dev/null | wc -l)
    echo "   ✅ scripts/: ${SC_COUNT} 个文件"
fi

# 6. templates/ 目录
echo "6️⃣  复制 templates/ 目录..."
if [ -d "${SOURCE_DIR}/templates" ]; then
    cp -r "${SOURCE_DIR}/templates" "${BACKUP_DIR}/"
    TP_COUNT=$(find "${SOURCE_DIR}/templates" -name "*.html" 2>/dev/null | wc -l)
    echo "   ✅ templates/: ${TP_COUNT} 个HTML文件"
fi

# 7. static/ 目录
echo "7️⃣  复制 static/ 目录..."
if [ -d "${SOURCE_DIR}/static" ]; then
    cp -r "${SOURCE_DIR}/static" "${BACKUP_DIR}/"
    ST_COUNT=$(find "${SOURCE_DIR}/static" -type f 2>/dev/null | wc -l)
    echo "   ✅ static/: ${ST_COUNT} 个文件"
fi

# 8. 配置文件
echo "8️⃣  复制配置文件..."
mkdir -p "${BACKUP_DIR}/configs"
find "${SOURCE_DIR}" -maxdepth 1 \( -name "*.json" -o -name "*.js" -o -name "ecosystem.config*.js" \) -exec cp {} "${BACKUP_DIR}/configs/" \; 2>/dev/null || true
CONFIG_COUNT=$(ls "${BACKUP_DIR}/configs" 2>/dev/null | wc -l)
echo "   ✅ 配置文件: ${CONFIG_COUNT} 个"

# 9. 依赖文件
echo "9️⃣  复制依赖文件..."
[ -f "${SOURCE_DIR}/requirements.txt" ] && cp "${SOURCE_DIR}/requirements.txt" "${BACKUP_DIR}/"
[ -f "${SOURCE_DIR}/package.json" ] && cp "${SOURCE_DIR}/package.json" "${BACKUP_DIR}/"
echo "   ✅ 依赖文件"

# 10. Markdown文档
echo "🔟 复制所有Markdown文档..."
mkdir -p "${BACKUP_DIR}/docs"
find "${SOURCE_DIR}" -maxdepth 1 -name "*.md" -exec cp {} "${BACKUP_DIR}/docs/" \; 2>/dev/null || true
MD_COUNT=$(find "${SOURCE_DIR}" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l)
echo "   ✅ Markdown文档: ${MD_COUNT} 个"

# 11. 数据文件
echo "1️⃣1️⃣  复制数据目录（这可能需要几分钟）..."
if [ -d "${SOURCE_DIR}/data" ]; then
    mkdir -p "${BACKUP_DIR}/data"
    # 排除backups, logs, node_modules, __pycache__
    cd "${SOURCE_DIR}/data"
    find . -type d \( -name backups -o -name logs -o -name node_modules -o -name __pycache__ \) -prune -o -type f -print | while read file; do
        mkdir -p "${BACKUP_DIR}/data/$(dirname "$file")"
        cp "$file" "${BACKUP_DIR}/data/$file" 2>/dev/null || true
    done
    cd "${SOURCE_DIR}"
    DATA_SIZE=$(du -sh "${BACKUP_DIR}/data" 2>/dev/null | cut -f1)
    echo "   ✅ data/: ${DATA_SIZE}"
fi

# 12. PM2配置
echo "1️⃣2️⃣  导出PM2配置..."
pm2 save --force 2>/dev/null || true
if [ -f "$HOME/.pm2/dump.pm2" ]; then
    cp "$HOME/.pm2/dump.pm2" "${BACKUP_DIR}/configs/pm2_dump.pm2"
    echo "   ✅ PM2进程配置"
fi

# 13. 创建系统信息和部署指南
echo "1️⃣3️⃣  生成系统信息和部署指南..."

cat > "${BACKUP_DIR}/SYSTEM_INFO.txt" << EOF
====================================================
系统备份信息
====================================================
备份时间: $(date '+%Y-%m-%d %H:%M:%S')
备份版本: ${BACKUP_DATE}
源目录: ${SOURCE_DIR}

====================================================
备份内容统计
====================================================
Python文件: $(find "${BACKUP_DIR}" -name "*.py" 2>/dev/null | wc -l) 个
HTML模板: $(find "${BACKUP_DIR}" -name "*.html" 2>/dev/null | wc -l) 个
Markdown文档: ${MD_COUNT} 个
配置文件: ${CONFIG_COUNT} 个

====================================================
目录大小
====================================================
$(du -sh "${BACKUP_DIR}"/* 2>/dev/null | sort -hr)
EOF

# 简化的部署指南
cat > "${BACKUP_DIR}/README.md" << 'EOF'
# 系统重新部署指南

## 快速开始

1. 解压备份
```bash
tar -xzf webapp_complete_backup_*.tar.gz
cd webapp_complete_backup_*
```

2. 安装依赖
```bash
pip3 install -r requirements.txt
```

3. 启动Flask
```bash
pm2 start app.py --name flask-app --interpreter python3
```

4. 启动采集器
```bash
# 使用PM2配置文件
cd configs
for cfg in ecosystem.config*.js; do pm2 start "$cfg"; done
```

5. 查看状态
```bash
pm2 list
pm2 logs
```

详细说明请查看 SYSTEM_INFO.txt
EOF

echo "   ✅ 系统信息和部署指南"

# 压缩
echo ""
echo "======================================================"
echo "📦 压缩备份文件（这可能需要几分钟）..."
echo "======================================================"
cd /tmp
tar -czf "${BACKUP_FILE}" "${BACKUP_NAME}" 2>&1 | while read line; do echo "   $line"; done || true

BACKUP_SIZE=$(du -sh "${BACKUP_FILE}" 2>/dev/null | cut -f1)

# 清理临时目录
rm -rf "${BACKUP_DIR}"

echo ""
echo "======================================================"
echo "✅ 备份完成！"
echo "======================================================"
echo "📦 备份文件: ${BACKUP_FILE}"
echo "💾 文件大小: ${BACKUP_SIZE}"
echo "📅 备份时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "🔍 验证备份文件..."
tar -tzf "${BACKUP_FILE}" 2>/dev/null | head -20
echo "..."
FILE_COUNT=$(tar -tzf "${BACKUP_FILE}" 2>/dev/null | wc -l)
echo "总计文件数: ${FILE_COUNT}"
echo ""
echo "======================================================"
echo "📋 使用方法:"
echo "1. 解压: tar -xzf ${BACKUP_FILE}"
echo "2. 查看: cat webapp_complete_backup_*/README.md"
echo "======================================================"
