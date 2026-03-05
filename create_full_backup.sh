#!/bin/bash
# 完整项目备份脚本
# 创建时间: 2026-03-05
# 备份所有代码、配置、数据文件到 /tmp 目录

set -e

echo "======================================"
echo "🚀 开始创建完整项目备份"
echo "======================================"
echo ""

# 备份配置
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="okx_trading_webapp_full_backup_${BACKUP_DATE}"
BACKUP_DIR="/tmp/${BACKUP_NAME}"
BACKUP_FILE="/tmp/${BACKUP_NAME}.tar.gz"
SOURCE_DIR="/home/user/webapp"

echo "📦 备份信息:"
echo "  源目录: ${SOURCE_DIR}"
echo "  备份目录: ${BACKUP_DIR}"
echo "  压缩文件: ${BACKUP_FILE}"
echo ""

# 创建临时备份目录
echo "📁 创建临时备份目录..."
mkdir -p "${BACKUP_DIR}"

# 创建备份清单文件
echo "📝 创建备份清单..."
cat > "${BACKUP_DIR}/BACKUP_MANIFEST.txt" << 'EOF'
====================================
OKX Trading WebApp - 完整备份清单
====================================

备份时间: $(date +"%Y-%m-%d %H:%M:%S")
备份版本: v1.0-full
备份说明: 包含所有代码、配置、数据文件的完整备份

====================================
1. 目录结构
====================================

webapp/
├── app.py                          # Flask主应用 (9002端口)
├── requirements.txt                # Python依赖
├── package.json                    # Node.js依赖 (PM2)
├── ecosystem.config.js             # PM2进程配置
├── backfill_up_ratio.py           # 数据回填脚本
│
├── monitors/                       # 监控器目录
│   ├── coin_change_prediction_monitor.py    # 预判监控
│   ├── coin_change_tracker.py              # 涨跌追踪
│   ├── market_sentiment_collector.py       # 市场情绪
│   └── ... (更多监控器)
│
├── collectors/                     # 数据采集器
│   ├── okx_*.py                   # OKX API采集器
│   └── ... (更多采集器)
│
├── managers/                       # 管理器
│   ├── gdrive_jsonl_manager.py    # Google Drive同步
│   ├── dashboard_jsonl_manager.py  # 仪表板数据
│   └── ... (更多管理器)
│
├── templates/                      # HTML模板
│   ├── coin_change_tracker.html   # 涨跌追踪页面
│   ├── panic_paged_v2.html        # 恐慌洗盘v2页面
│   ├── panic_v3.html              # 恐慌洗盘v3页面
│   └── ... (更多模板)
│
├── static/                         # 静态资源
│   ├── css/
│   ├── js/
│   └── images/
│
├── source_code/                    # 源代码API
│   └── ... (Python API文件)
│
├── panic_paged_v2/                 # 恐慌洗盘v2系统
│   └── ... (相关文件)
│
├── panic_v3/                       # 恐慌洗盘v3系统
│   └── ... (相关文件)
│
├── major-events-system/            # 重大事件系统
│   └── ... (相关文件)
│
├── data/                           # 数据目录
│   ├── coin_change_tracker/       # 涨跌数据
│   ├── daily_predictions/         # 预判数据
│   ├── market_sentiment/          # 市场情绪
│   ├── sar_jsonl/                 # SAR数据
│   ├── panic_jsonl/               # 恐慌洗盘数据
│   └── ... (更多数据目录)
│
├── docs/                           # 文档目录
│   ├── API文档/
│   ├── 系统说明/
│   └── 修复报告/
│
└── config/                         # 配置文件
    ├── okx_config.json
    └── ... (更多配置)

====================================
2. 包含的文件类型
====================================

✅ Python文件 (.py)      - 所有应用代码、监控器、采集器
✅ HTML模板 (.html)       - Web界面模板
✅ Markdown文档 (.md)     - 系统文档、使用指南
✅ JSON配置 (.json)       - 配置文件
✅ JavaScript (.js)       - 前端脚本
✅ CSS样式 (.css)         - 样式文件
✅ Shell脚本 (.sh)        - 部署脚本、工具脚本
✅ JSONL数据 (.jsonl)     - 所有历史数据文件
✅ 配置文件              - requirements.txt, package.json, ecosystem.config.js

====================================
3. 排除的文件
====================================

❌ logs/                 - 日志文件 (65MB)
❌ node_modules/         - Node.js依赖 (34MB, 可通过npm install恢复)
❌ backups/              - 旧备份文件
❌ __pycache__/          - Python缓存
❌ .git/                 - Git仓库 (如果存在)
❌ *.pyc                 - Python编译文件
❌ .DS_Store             - macOS系统文件
❌ .env                  - 敏感环境变量 (需手动配置)

====================================
4. 数据文件统计
====================================

coin_change_tracker/     - 涨跌追踪数据 (~200MB)
daily_predictions/       - 预判数据 (~10MB)
market_sentiment/        - 市场情绪数据 (~50MB)
sar_jsonl/              - SAR指标数据 (~150MB)
panic_jsonl/            - 恐慌洗盘数据 (~100MB)
crash_warning_events/   - 崩盘预警数据 (~50MB)
price_position/         - 价格位置数据 (~80MB)
sar_bias_stats/         - SAR偏差统计 (~30MB)
... (其他数据目录)

总计: ~800MB 数据文件

====================================
5. 关键依赖
====================================

Python依赖 (requirements.txt):
- Flask>=2.3.0          # Web框架
- requests>=2.31.0      # HTTP请求
- pandas>=2.0.0         # 数据处理
- numpy>=1.24.0         # 数值计算
- python-dateutil       # 日期处理
- ... (更多依赖，见requirements.txt)

系统依赖 (apt):
- python3               # Python 3.12
- python3-pip           # Python包管理
- nodejs                # Node.js (PM2需要)
- npm                   # Node包管理

Node.js依赖 (package.json):
- pm2                   # 进程管理器

====================================
6. 服务端口
====================================

Flask应用: 9002        # Web界面主端口

====================================
7. PM2进程列表
====================================

flask-app                           # Flask主应用 (9002端口)
coin-change-predictor               # 预判监控器
coin-change-tracker                 # 涨跌追踪采集器
market-sentiment-collector          # 市场情绪采集器
coin-price-tracker                  # 价格追踪器
... (更多PM2进程，见ecosystem.config.js)

EOF

echo "✅ 备份清单创建完成"
echo ""

# 复制文件到备份目录
echo "📋 复制文件..."
echo ""

# 1. 复制Python文件
echo "  ✓ 复制Python文件..."
rsync -a --include='*.py' --exclude='*' "${SOURCE_DIR}/" "${BACKUP_DIR}/" 2>/dev/null || true

# 2. 复制所有代码目录
echo "  ✓ 复制代码目录..."
for dir in monitors collectors managers utils tools code source_code panic_paged_v2 panic_v3 major-events-system; do
    if [ -d "${SOURCE_DIR}/${dir}" ]; then
        rsync -a "${SOURCE_DIR}/${dir}" "${BACKUP_DIR}/" \
            --exclude='__pycache__' \
            --exclude='*.pyc' \
            --exclude='.DS_Store' 2>/dev/null || true
        echo "    - ${dir}/"
    fi
done

# 3. 复制模板和静态文件
echo "  ✓ 复制Web资源..."
for dir in templates static; do
    if [ -d "${SOURCE_DIR}/${dir}" ]; then
        rsync -a "${SOURCE_DIR}/${dir}" "${BACKUP_DIR}/" 2>/dev/null || true
        echo "    - ${dir}/"
    fi
done

# 4. 复制文档
echo "  ✓ 复制文档..."
if [ -d "${SOURCE_DIR}/docs" ]; then
    rsync -a "${SOURCE_DIR}/docs" "${BACKUP_DIR}/" 2>/dev/null || true
    echo "    - docs/"
fi

# 5. 复制配置文件
echo "  ✓ 复制配置文件..."
for file in app.py requirements.txt package.json ecosystem.config.js backfill_up_ratio.py; do
    if [ -f "${SOURCE_DIR}/${file}" ]; then
        cp "${SOURCE_DIR}/${file}" "${BACKUP_DIR}/"
        echo "    - ${file}"
    fi
done

# 复制config目录（如果存在）
if [ -d "${SOURCE_DIR}/config" ]; then
    rsync -a "${SOURCE_DIR}/config" "${BACKUP_DIR}/" \
        --exclude='.env' \
        --exclude='*secret*' \
        --exclude='*key*' 2>/dev/null || true
    echo "    - config/"
fi

# 6. 复制根目录下的其他Python文件
echo "  ✓ 复制根目录Python文件..."
find "${SOURCE_DIR}" -maxdepth 1 -type f -name "*.py" -exec cp {} "${BACKUP_DIR}/" \; 2>/dev/null || true

# 7. 复制所有数据文件 (不限制7天)
echo "  ✓ 复制数据文件 (完整历史数据)..."
if [ -d "${SOURCE_DIR}/data" ]; then
    echo "    正在复制数据目录，这可能需要几分钟..."
    
    # 使用cp代替rsync以确保完整复制
    cp -r "${SOURCE_DIR}/data" "${BACKUP_DIR}/" 2>/dev/null || {
        echo "    ⚠️  cp failed, trying rsync..."
        rsync -a "${SOURCE_DIR}/data/" "${BACKUP_DIR}/data/" \
            --exclude='*.log' \
            --exclude='__pycache__' 2>/dev/null || true
    }
    
    # 清理日志文件
    find "${BACKUP_DIR}/data" -name "*.log" -delete 2>/dev/null || true
    find "${BACKUP_DIR}/data" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    
    echo "    - data/ (完整)"
fi

echo ""
echo "📊 统计备份大小..."
BACKUP_SIZE=$(du -sh "${BACKUP_DIR}" | cut -f1)
echo "  备份目录大小: ${BACKUP_SIZE}"
echo ""

# 压缩备份
echo "🗜️  压缩备份文件..."
cd /tmp
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}" 2>/dev/null

if [ -f "${BACKUP_FILE}" ]; then
    COMPRESSED_SIZE=$(du -sh "${BACKUP_FILE}" | cut -f1)
    echo "✅ 压缩完成: ${COMPRESSED_SIZE}"
    echo ""
    
    # 清理临时目录
    echo "🧹 清理临时文件..."
    rm -rf "${BACKUP_DIR}"
    
    echo ""
    echo "======================================"
    echo "✅ 备份创建完成！"
    echo "======================================"
    echo ""
    echo "📦 备份文件: ${BACKUP_FILE}"
    echo "📊 文件大小: ${COMPRESSED_SIZE}"
    echo ""
    echo "📝 下一步操作:"
    echo "  1. 下载备份文件到本地"
    echo "  2. 查看部署说明: 解压后查看 DEPLOYMENT_GUIDE.md"
    echo "  3. 在新服务器上部署"
    echo ""
else
    echo "❌ 备份失败！"
    exit 1
fi
