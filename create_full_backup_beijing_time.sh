#!/bin/bash

# ================================================================
# 完整系统备份脚本 V3.1 - 使用北京时间
# 创建日期: 2026-03-07
# 用途: 备份整个 webapp 项目（约2GB），使用北京时间命名
# ================================================================

set -e

# 使用北京时间
export TZ='Asia/Shanghai'
BEIJING_TIME=$(date +"%Y%m%d_%H%M%S")
BEIJING_READABLE=$(date +"%Y-%m-%d %H:%M:%S")

SOURCE_DIR="/home/user/webapp"
BACKUP_BASE_DIR="/tmp"
BACKUP_NAME="webapp_full_backup_${BEIJING_TIME}"
BACKUP_DIR="${BACKUP_BASE_DIR}/${BACKUP_NAME}"
BACKUP_ARCHIVE="${BACKUP_BASE_DIR}/${BACKUP_NAME}.tar.gz"

echo "================================================================"
echo "完整系统备份 V3.1 - 使用北京时间"
echo "================================================================"
echo "开始时间 (北京): ${BEIJING_READABLE}"
echo "源目录: ${SOURCE_DIR}"
echo "备份目录: ${BACKUP_DIR}"
echo "备份文件: ${BACKUP_ARCHIVE}"
echo ""

# 删除旧备份
echo "🗑️  删除旧备份..."
rm -rf /tmp/webapp_full_backup_*.tar.gz 2>/dev/null || true
rm -rf /tmp/webapp_complete_backup_*.tar.gz 2>/dev/null || true

# 创建备份目录结构
mkdir -p "${BACKUP_DIR}"/{code,configs,data,scripts,templates,static,docs,system_info}

echo "📦 开始复制文件..."

# 1. 复制根目录Python文件
echo "  ✓ 复制根目录Python文件..."
find "${SOURCE_DIR}" -maxdepth 1 -name "*.py" -exec cp {} "${BACKUP_DIR}/code/" \;
cp "${SOURCE_DIR}/app.py" "${BACKUP_DIR}/code/" 2>/dev/null || true

# 2. 复制source_code目录
if [ -d "${SOURCE_DIR}/source_code" ]; then
    echo "  ✓ 复制source_code目录..."
    cp -r "${SOURCE_DIR}/source_code" "${BACKUP_DIR}/code/"
fi

# 3. 复制panic相关目录
for dir in panic_paged_v2 panic_v3; do
    if [ -d "${SOURCE_DIR}/${dir}" ]; then
        echo "  ✓ 复制${dir}目录..."
        cp -r "${SOURCE_DIR}/${dir}" "${BACKUP_DIR}/code/"
    fi
done

# 4. 复制major-events-system
if [ -d "${SOURCE_DIR}/major-events-system" ]; then
    echo "  ✓ 复制major-events-system目录..."
    cp -r "${SOURCE_DIR}/major-events-system" "${BACKUP_DIR}/code/"
fi

# 5. 复制scripts目录
if [ -d "${SOURCE_DIR}/scripts" ]; then
    echo "  ✓ 复制scripts目录..."
    cp -r "${SOURCE_DIR}/scripts" "${BACKUP_DIR}/scripts/"
fi

# 6. 复制templates目录
if [ -d "${SOURCE_DIR}/templates" ]; then
    echo "  ✓ 复制templates目录..."
    cp -r "${SOURCE_DIR}/templates" "${BACKUP_DIR}/templates/"
fi

# 7. 复制static目录
if [ -d "${SOURCE_DIR}/static" ]; then
    echo "  ✓ 复制static目录..."
    cp -r "${SOURCE_DIR}/static" "${BACKUP_DIR}/static/"
fi

# 8. 复制配置文件
echo "  ✓ 复制配置文件..."
find "${SOURCE_DIR}" -maxdepth 1 -name "ecosystem.config*.js" -exec cp {} "${BACKUP_DIR}/configs/" \;
cp "${SOURCE_DIR}/requirements.txt" "${BACKUP_DIR}/configs/" 2>/dev/null || true
cp "${SOURCE_DIR}/package.json" "${BACKUP_DIR}/configs/" 2>/dev/null || true
cp "${SOURCE_DIR}/package-lock.json" "${BACKUP_DIR}/configs/" 2>/dev/null || true
cp "${SOURCE_DIR}/.env" "${BACKUP_DIR}/configs/" 2>/dev/null || true
find "${SOURCE_DIR}" -maxdepth 1 -name "*.json" -not -name "package*.json" -exec cp {} "${BACKUP_DIR}/configs/" \;

# 9. 复制.git文件（但不包括大的objects）
if [ -d "${SOURCE_DIR}/.git" ]; then
    echo "  ✓ 复制.git配置..."
    mkdir -p "${BACKUP_DIR}/.git"
    cp "${SOURCE_DIR}/.git/config" "${BACKUP_DIR}/.git/" 2>/dev/null || true
    cp "${SOURCE_DIR}/.git/HEAD" "${BACKUP_DIR}/.git/" 2>/dev/null || true
    cp -r "${SOURCE_DIR}/.git/refs" "${BACKUP_DIR}/.git/" 2>/dev/null || true
fi

# 10. 复制Markdown文档
echo "  ✓ 复制Markdown文档..."
find "${SOURCE_DIR}" -maxdepth 1 -name "*.md" -exec cp {} "${BACKUP_DIR}/docs/" \;
cp "${SOURCE_DIR}/README.md" "${BACKUP_DIR}/" 2>/dev/null || true
cp "${SOURCE_DIR}/LICENSE" "${BACKUP_DIR}/" 2>/dev/null || true

# 11. 复制data目录（最大的部分）
if [ -d "${SOURCE_DIR}/data" ]; then
    echo "  ✓ 复制data目录（约3.1GB，请稍候）..."
    cp -r "${SOURCE_DIR}/data" "${BACKUP_DIR}/data/"
fi

# 12. 导出系统信息
echo "📊 导出系统信息..."

# PM2进程列表
pm2 list > "${BACKUP_DIR}/system_info/pm2_processes.txt" 2>&1 || echo "PM2 not available" > "${BACKUP_DIR}/system_info/pm2_processes.txt"
pm2 jlist > "${BACKUP_DIR}/system_info/pm2_processes.json" 2>&1 || echo "[]" > "${BACKUP_DIR}/system_info/pm2_processes.json"
pm2 save > /dev/null 2>&1 || true
cp ~/.pm2/dump.pm2 "${BACKUP_DIR}/system_info/pm2_dump.pm2" 2>/dev/null || true

# Flask路由列表
cd "${SOURCE_DIR}" && python3 << 'PYEOF' > "${BACKUP_DIR}/system_info/flask_routes.txt" 2>&1 || true
import sys
sys.path.insert(0, '/home/user/webapp')
try:
    from app import app
    routes = []
    for rule in app.url_map.iter_rules():
        routes.append(f"{rule.endpoint:50s} {rule.methods} {rule.rule}")
    print(f"Total Flask Routes: {len(routes)}\n")
    print("\n".join(sorted(routes)))
except Exception as e:
    print(f"Error extracting routes: {e}")
PYEOF

# Python包列表
pip3 list > "${BACKUP_DIR}/system_info/pip_packages.txt" 2>&1
pip3 freeze > "${BACKUP_DIR}/system_info/pip_packages_freeze.txt" 2>&1

# APT包列表
dpkg -l > "${BACKUP_DIR}/system_info/apt_packages_full.txt" 2>&1
dpkg --get-selections > "${BACKUP_DIR}/system_info/apt_packages_selections.txt" 2>&1

# 系统信息摘要
cat > "${BACKUP_DIR}/system_info/SYSTEM_INFO.txt" << SYSEOF
================================================================
系统备份信息 - 北京时间
================================================================
备份时间 (北京): ${BEIJING_READABLE}
备份时间 (UTC): $(TZ='UTC' date +"%Y-%m-%d %H:%M:%S")
源目录: ${SOURCE_DIR}
备份名称: ${BACKUP_NAME}

Python版本: $(python3 --version)
Node.js版本: $(node --version 2>/dev/null || echo "Not installed")
npm版本: $(npm --version 2>/dev/null || echo "Not installed")
PM2版本: $(pm2 --version 2>/dev/null || echo "Not installed")

系统信息:
$(uname -a)

磁盘使用:
$(df -h /home/user/webapp 2>/dev/null || echo "N/A")

Git分支:
$(cd ${SOURCE_DIR} && git branch 2>/dev/null | grep '*' || echo "N/A")

Git最新提交:
$(cd ${SOURCE_DIR} && git log -1 --oneline 2>/dev/null || echo "N/A")
SYSEOF

# 13. 创建部署指南
cat > "${BACKUP_DIR}/DEPLOYMENT_GUIDE.md" << 'DEPEOF'
# 完整系统部署指南

## 📦 备份内容概览

### 文件统计
| 文件类型 | 数量 | 总大小 | 占比 | 说明 |
|---------|------|--------|------|------|
| Python文件 | ~148 | ~5MB | <1% | app.py + source_code + 根目录 |
| HTML模板 | ~126 | ~2MB | <1% | templates/*.html |
| JavaScript配置 | ~15 | <1MB | <1% | ecosystem.config*.js |
| JSON配置 | ~12 | <1MB | <1% | 各种配置文件 |
| Markdown文档 | ~233 | ~15MB | <1% | 技术文档和使用指南 |
| 数据文件 | ~2,307 | ~3.1GB | >95% | data/**/*.jsonl |
| **总计** | **~3,029** | **~3.2GB** | **100%** | 完整项目 |

### 关键组件

#### 1. Flask应用 (app.py)
- 主应用文件，包含所有API路由
- 端口: 9002
- 路由数量: ~200+

#### 2. PM2服务管理
所有服务配置文件都在 `configs/` 目录:
- `ecosystem.config.js` - 主服务配置
- `ecosystem.config.*.js` - 各监控服务配置

#### 3. Python依赖
- Flask框架及扩展
- ccxt (交易所API)
- requests, pandas等数据处理库
- 完整列表见 `configs/requirements.txt`

#### 4. 系统级依赖 (APT)
- python3, python3-pip
- nodejs, npm
- git
- 完整列表见 `system_info/apt_packages_selections.txt`

## 🚀 快速部署步骤

### 1. 解压备份
```bash
cd /tmp
tar -xzf webapp_full_backup_YYYYMMDD_HHMMSS.tar.gz
cd webapp_full_backup_YYYYMMDD_HHMMSS
```

### 2. 查看系统信息
```bash
cat system_info/SYSTEM_INFO.txt
cat system_info/flask_routes.txt | head -20
```

### 3. 复制文件到目标位置
```bash
TARGET_DIR="/home/user/webapp"
mkdir -p ${TARGET_DIR}

# 复制代码
cp -r code/* ${TARGET_DIR}/
cp -r scripts ${TARGET_DIR}/
cp -r templates ${TARGET_DIR}/
cp -r static ${TARGET_DIR}/

# 复制配置
cp configs/* ${TARGET_DIR}/

# 复制数据（最大）
cp -r data ${TARGET_DIR}/

# 复制文档
cp -r docs/* ${TARGET_DIR}/
cp README.md ${TARGET_DIR}/ 2>/dev/null || true
```

### 4. 安装Python依赖
```bash
cd ${TARGET_DIR}
pip3 install -r requirements.txt
```

### 5. 启动服务

#### 方法A: 使用PM2批量启动
```bash
cd ${TARGET_DIR}
# 启动主Flask应用
pm2 start app.py --name flask-app --interpreter python3

# 启动所有监控服务
for config in ecosystem.config*.js; do
    pm2 start "$config"
done

# 查看状态
pm2 list
pm2 logs --lines 50
```

#### 方法B: 使用快速启动脚本
```bash
cd ${TARGET_DIR}
./quick_start.sh
```

### 6. 验证部署
```bash
# 检查PM2服务
pm2 status

# 测试Flask API
curl http://localhost:9002/api/health

# 查看最新数据
ls -lh ${TARGET_DIR}/data/coin_change_tracker/ | tail -5
```

## 🔧 服务管理

### Flask应用
```bash
pm2 start app.py --name flask-app --interpreter python3
pm2 logs flask-app
pm2 restart flask-app
```

### 数据采集器
```bash
pm2 start ecosystem.config.js
pm2 logs coin-change-tracker
```

### 监控服务
```bash
# 底部信号监控
pm2 logs bottom-signal-long-monitor

# 条件单监控
pm2 logs coin-change-conditional-order-monitor

# 正数占比监控
pm2 logs positive-ratio-monitor

# 5分钟涨速监控
pm2 logs five-min-speed-crash-monitor
```

## 📊 数据目录结构

```
data/
├── coin_change_tracker/        # 主数据目录
│   ├── coin_change_20260307.jsonl
│   └── coin_change_YYYYMMDD.jsonl
├── sar_jsonl/                  # SAR指标数据
├── positive_ratio_monitor/     # 正数占比监控
├── five_min_speed_monitor/     # 5分钟涨速监控
└── [其他监控数据目录]
```

## 🌐 路由映射

### 核心API端点
- `/coin-change-tracker` - 主页面
- `/api/coin-change-tracker/latest` - 最新数据
- `/api/coin-change-tracker/history` - 历史数据
- `/api/coin-change-tracker/velocity-history` - 涨速历史
- `/api/coin-change-tracker/positive-ratio-history` - 正数占比历史
- `/sar-slope` - SAR偏向趋势图
- 更多路由见 `system_info/flask_routes.txt`

## ⚠️ 注意事项

1. **Telegram配置**: 确保 `.env` 文件中配置了正确的Telegram Bot Token
2. **端口占用**: Flask默认使用9002端口，确保未被占用
3. **数据权限**: 确保data目录有写权限
4. **PM2守护进程**: 首次部署后运行 `pm2 startup` 和 `pm2 save`
5. **系统时区**: 建议使用北京时间 `export TZ='Asia/Shanghai'`

## 📝 故障排查

### Flask无法启动
```bash
# 检查Python路径
which python3
python3 --version

# 检查依赖
pip3 list | grep -i flask

# 查看错误日志
pm2 logs flask-app --err --lines 100
```

### 数据采集器不工作
```bash
# 检查PM2状态
pm2 status

# 重启采集器
pm2 restart coin-change-tracker

# 查看实时日志
pm2 logs coin-change-tracker --lines 50
```

### API返回404
```bash
# 验证路由是否注册
cd /home/user/webapp
python3 -c "from app import app; print([str(r) for r in app.url_map.iter_rules()])"
```

## 🔗 相关资源

- GitHub仓库: https://github.com/jamesyidc/1122112211110306
- 分支: deployment/complete-okx-trading-system
- PM2文档: https://pm2.keymetrics.io/
- Flask文档: https://flask.palletsprojects.com/

---
备份创建时间 (北京): ${BEIJING_READABLE}
备份脚本版本: V3.1
DEPEOF

# 14. 创建快速启动脚本
cat > "${BACKUP_DIR}/quick_start.sh" << 'QSEOF'
#!/bin/bash
set -e

echo "🚀 开始快速部署..."

TARGET_DIR="/home/user/webapp"

# 1. 安装Python依赖
echo "📦 安装Python依赖..."
cd ${TARGET_DIR}
pip3 install -r configs/requirements.txt

# 2. 启动Flask
echo "🌐 启动Flask应用..."
pm2 start code/app.py --name flask-app --interpreter python3

# 3. 启动所有PM2服务
echo "⚙️  启动监控服务..."
cd configs
for config in ecosystem.config*.js; do
    echo "  启动 $config"
    pm2 start "$config"
done

# 4. 显示状态
echo ""
echo "✅ 部署完成！"
pm2 list
echo ""
echo "📊 Web界面: http://localhost:9002/coin-change-tracker"
echo "📝 查看日志: pm2 logs"
QSEOF

chmod +x "${BACKUP_DIR}/quick_start.sh"

# 15. 统计文件信息
echo ""
echo "📊 统计备份内容..."

COUNT_ROOT_PY=$(find "${BACKUP_DIR}/code" -maxdepth 1 -name "*.py" 2>/dev/null | wc -l)
COUNT_SOURCE_PY=$(find "${BACKUP_DIR}/code/source_code" -name "*.py" 2>/dev/null | wc -l)
COUNT_PANIC2=$(find "${BACKUP_DIR}/code/panic_paged_v2" -type f 2>/dev/null | wc -l)
COUNT_PANIC3=$(find "${BACKUP_DIR}/code/panic_v3" -type f 2>/dev/null | wc -l)
COUNT_SCRIPTS=$(find "${BACKUP_DIR}/scripts" -type f 2>/dev/null | wc -l)
COUNT_TEMPLATES=$(find "${BACKUP_DIR}/templates" -name "*.html" 2>/dev/null | wc -l)
COUNT_STATIC=$(find "${BACKUP_DIR}/static" -type f 2>/dev/null | wc -l)
COUNT_CONFIGS=$(find "${BACKUP_DIR}/configs" -type f 2>/dev/null | wc -l)
COUNT_DOCS=$(find "${BACKUP_DIR}/docs" -name "*.md" 2>/dev/null | wc -l)
COUNT_DATA=$(find "${BACKUP_DIR}/data" -type f 2>/dev/null | wc -l)
SIZE_DATA=$(du -sh "${BACKUP_DIR}/data" 2>/dev/null | cut -f1)

TOTAL_FILES=$((COUNT_ROOT_PY + COUNT_SOURCE_PY + COUNT_PANIC2 + COUNT_PANIC3 + COUNT_SCRIPTS + COUNT_TEMPLATES + COUNT_STATIC + COUNT_CONFIGS + COUNT_DOCS + COUNT_DATA))

cat > "${BACKUP_DIR}/BACKUP_INVENTORY.txt" << INVEOF
================================================================
备份清单 - 北京时间 ${BEIJING_READABLE}
================================================================

代码文件:
  ├─ 根目录Python文件: ${COUNT_ROOT_PY}
  ├─ source_code Python: ${COUNT_SOURCE_PY}
  ├─ panic_paged_v2: ${COUNT_PANIC2}
  ├─ panic_v3: ${COUNT_PANIC3}
  └─ 脚本文件: ${COUNT_SCRIPTS}

前端文件:
  ├─ HTML模板: ${COUNT_TEMPLATES}
  └─ 静态资源: ${COUNT_STATIC}

配置文件: ${COUNT_CONFIGS}
  ├─ PM2配置 (ecosystem.config*.js)
  ├─ requirements.txt
  └─ 其他JSON配置

文档: ${COUNT_DOCS} 个Markdown文件

数据文件: ${COUNT_DATA} 个文件 (约 ${SIZE_DATA})
  ├─ coin_change_tracker/*.jsonl
  ├─ sar_jsonl/*.jsonl
  └─ 各监控服务数据

系统信息文件:
  ├─ PM2进程列表
  ├─ Flask路由列表 (~200+ 路由)
  ├─ Python包列表
  └─ APT包列表

总文件数: ${TOTAL_FILES}

================================================================
备份文件: ${BACKUP_ARCHIVE}
================================================================
INVEOF

echo ""
echo "  ✓ 根目录Python文件: ${COUNT_ROOT_PY}"
echo "  ✓ source_code Python: ${COUNT_SOURCE_PY}"
echo "  ✓ panic_paged_v2: ${COUNT_PANIC2}"
echo "  ✓ panic_v3: ${COUNT_PANIC3}"
echo "  ✓ 脚本文件: ${COUNT_SCRIPTS}"
echo "  ✓ HTML模板: ${COUNT_TEMPLATES}"
echo "  ✓ 静态资源: ${COUNT_STATIC}"
echo "  ✓ 配置文件: ${COUNT_CONFIGS}"
echo "  ✓ Markdown文档: ${COUNT_DOCS}"
echo "  ✓ 数据文件: ${COUNT_DATA} (${SIZE_DATA})"
echo ""

# 16. 压缩备份
echo "🗜️  压缩备份文件..."
cd "${BACKUP_BASE_DIR}"
tar -czf "${BACKUP_ARCHIVE}" "${BACKUP_NAME}/"

# 17. 验证备份
if [ -f "${BACKUP_ARCHIVE}" ]; then
    ARCHIVE_SIZE=$(du -h "${BACKUP_ARCHIVE}" | cut -f1)
    echo ""
    echo "================================================================"
    echo "✅ 备份完成 (北京时间)！"
    echo "================================================================"
    echo "备份文件: ${BACKUP_ARCHIVE}"
    echo "压缩大小: ${ARCHIVE_SIZE}"
    echo "原始大小: ~3.2GB"
    echo "总文件数: ${TOTAL_FILES}"
    echo "完成时间 (北京): $(date +"%Y-%m-%d %H:%M:%S")"
    echo "完成时间 (UTC): $(TZ='UTC' date +"%Y-%m-%d %H:%M:%S")"
    echo ""
    echo "📖 使用说明:"
    echo "  1. 解压: tar -xzf ${BACKUP_ARCHIVE}"
    echo "  2. 查看清单: cat ${BACKUP_NAME}/BACKUP_INVENTORY.txt"
    echo "  3. 阅读部署指南: cat ${BACKUP_NAME}/DEPLOYMENT_GUIDE.md"
    echo "  4. 快速部署: cd ${BACKUP_NAME} && ./quick_start.sh"
    echo "================================================================"
    
    # 清理临时目录
    rm -rf "${BACKUP_DIR}"
else
    echo "❌ 备份失败！"
    exit 1
fi
