#!/bin/bash
# 完整系统备份脚本 - 包含所有代码、配置、文档、数据
# 备份日期: 2026-03-07

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
find "${SOURCE_DIR}" -maxdepth 1 -type f -name "*.py" -exec cp {} "${BACKUP_DIR}/" \;
PY_COUNT=$(find "${SOURCE_DIR}" -maxdepth 1 -type f -name "*.py" | wc -l)
echo "   ✅ 根目录Python文件: ${PY_COUNT} 个"

# 2. app.py (主应用)
echo "2️⃣  复制主应用文件..."
if [ -f "${SOURCE_DIR}/app.py" ]; then
    cp "${SOURCE_DIR}/app.py" "${BACKUP_DIR}/"
    echo "   ✅ app.py (主Flask应用)"
fi

# 3. source_code/ 目录（所有Python API文件）
echo "3️⃣  复制 source_code/ 目录..."
if [ -d "${SOURCE_DIR}/source_code" ]; then
    cp -r "${SOURCE_DIR}/source_code" "${BACKUP_DIR}/"
    SC_COUNT=$(find "${SOURCE_DIR}/source_code" -name "*.py" | wc -l)
    echo "   ✅ source_code/: ${SC_COUNT} 个Python文件"
fi

# 4. panic_paged_v2/ 目录
echo "4️⃣  复制 panic_paged_v2/ 目录..."
if [ -d "${SOURCE_DIR}/panic_paged_v2" ]; then
    cp -r "${SOURCE_DIR}/panic_paged_v2" "${BACKUP_DIR}/"
    PP_COUNT=$(find "${SOURCE_DIR}/panic_paged_v2" -type f | wc -l)
    echo "   ✅ panic_paged_v2/: ${PP_COUNT} 个文件"
fi

# 5. panic_v3/ 目录
echo "5️⃣  复制 panic_v3/ 目录..."
if [ -d "${SOURCE_DIR}/panic_v3" ]; then
    cp -r "${SOURCE_DIR}/panic_v3" "${BACKUP_DIR}/"
    PV_COUNT=$(find "${SOURCE_DIR}/panic_v3" -type f | wc -l)
    echo "   ✅ panic_v3/: ${PV_COUNT} 个文件"
fi

# 6. major-events-system/ 目录
echo "6️⃣  复制 major-events-system/ 目录..."
if [ -d "${SOURCE_DIR}/major-events-system" ]; then
    cp -r "${SOURCE_DIR}/major-events-system" "${BACKUP_DIR}/"
    ME_COUNT=$(find "${SOURCE_DIR}/major-events-system" -type f | wc -l)
    echo "   ✅ major-events-system/: ${ME_COUNT} 个文件"
fi

# 7. scripts/ 目录（所有脚本）
echo "7️⃣  复制 scripts/ 目录..."
if [ -d "${SOURCE_DIR}/scripts" ]; then
    cp -r "${SOURCE_DIR}/scripts" "${BACKUP_DIR}/"
    SC_COUNT=$(find "${SOURCE_DIR}/scripts" -type f | wc -l)
    echo "   ✅ scripts/: ${SC_COUNT} 个文件"
fi

# 8. templates/ 目录（HTML模板）
echo "8️⃣  复制 templates/ 目录..."
if [ -d "${SOURCE_DIR}/templates" ]; then
    cp -r "${SOURCE_DIR}/templates" "${BACKUP_DIR}/"
    TP_COUNT=$(find "${SOURCE_DIR}/templates" -name "*.html" | wc -l)
    echo "   ✅ templates/: ${TP_COUNT} 个HTML文件"
fi

# 9. static/ 目录（静态资源）
echo "9️⃣  复制 static/ 目录..."
if [ -d "${SOURCE_DIR}/static" ]; then
    cp -r "${SOURCE_DIR}/static" "${BACKUP_DIR}/"
    ST_COUNT=$(find "${SOURCE_DIR}/static" -type f | wc -l)
    echo "   ✅ static/: ${ST_COUNT} 个文件"
fi

# 10. 配置文件
echo "🔟 复制配置文件..."
mkdir -p "${BACKUP_DIR}/configs"
find "${SOURCE_DIR}" -maxdepth 1 \( -name "*.json" -o -name "*.js" -o -name "*.yaml" -o -name "*.yml" -o -name "*.toml" -o -name "*.ini" -o -name "*.conf" \) -exec cp {} "${BACKUP_DIR}/configs/" \; 2>/dev/null || true
CONFIG_COUNT=$(ls "${BACKUP_DIR}/configs" 2>/dev/null | wc -l)
echo "   ✅ 配置文件: ${CONFIG_COUNT} 个"

# 11. ecosystem.config.*.js 文件
echo "1️⃣1️⃣  复制PM2配置文件..."
find "${SOURCE_DIR}" -maxdepth 1 -name "ecosystem.config*.js" -exec cp {} "${BACKUP_DIR}/configs/" \;
PM2_COUNT=$(find "${SOURCE_DIR}" -maxdepth 1 -name "ecosystem.config*.js" | wc -l)
echo "   ✅ PM2配置: ${PM2_COUNT} 个文件"

# 12. requirements.txt 和 package.json
echo "1️⃣2️⃣  复制依赖文件..."
[ -f "${SOURCE_DIR}/requirements.txt" ] && cp "${SOURCE_DIR}/requirements.txt" "${BACKUP_DIR}/"
[ -f "${SOURCE_DIR}/package.json" ] && cp "${SOURCE_DIR}/package.json" "${BACKUP_DIR}/"
[ -f "${SOURCE_DIR}/package-lock.json" ] && cp "${SOURCE_DIR}/package-lock.json" "${BACKUP_DIR}/"
echo "   ✅ 依赖文件（requirements.txt, package.json）"

# 13. Markdown文档
echo "1️⃣3️⃣  复制所有Markdown文档..."
mkdir -p "${BACKUP_DIR}/docs"
find "${SOURCE_DIR}" -maxdepth 1 -name "*.md" -exec cp {} "${BACKUP_DIR}/docs/" \;
MD_COUNT=$(find "${SOURCE_DIR}" -maxdepth 1 -name "*.md" | wc -l)
echo "   ✅ Markdown文档: ${MD_COUNT} 个"

# 14. 数据文件（所有JSONL）
echo "1️⃣4️⃣  复制数据目录..."
if [ -d "${SOURCE_DIR}/data" ]; then
    # 排除backups目录
    rsync -av --exclude='backups/' "${SOURCE_DIR}/data/" "${BACKUP_DIR}/data/"
    DATA_SIZE=$(du -sh "${BACKUP_DIR}/data" | cut -f1)
    echo "   ✅ data/: ${DATA_SIZE}"
fi

# 15. .env 环境变量文件
echo "1️⃣5️⃣  复制环境变量文件..."
if [ -f "${SOURCE_DIR}/.env" ]; then
    cp "${SOURCE_DIR}/.env" "${BACKUP_DIR}/"
    echo "   ✅ .env 文件"
fi

# 16. .gitignore 和 .git 配置
echo "1️⃣6️⃣  复制Git配置..."
[ -f "${SOURCE_DIR}/.gitignore" ] && cp "${SOURCE_DIR}/.gitignore" "${BACKUP_DIR}/"
if [ -d "${SOURCE_DIR}/.git/config" ]; then
    mkdir -p "${BACKUP_DIR}/.git"
    cp "${SOURCE_DIR}/.git/config" "${BACKUP_DIR}/.git/" 2>/dev/null || true
fi
echo "   ✅ Git配置文件"

# 17. PM2生态系统配置（从PM2导出）
echo "1️⃣7️⃣  导出PM2配置..."
pm2 save --force 2>/dev/null || true
if [ -f "$HOME/.pm2/dump.pm2" ]; then
    cp "$HOME/.pm2/dump.pm2" "${BACKUP_DIR}/configs/pm2_dump.pm2"
    echo "   ✅ PM2进程配置"
fi

# 18. Flask应用路由清单
echo "1️⃣8️⃣  生成Flask路由清单..."
python3 << 'PYEOF' > "${BACKUP_DIR}/flask_routes.txt" 2>/dev/null || echo "无法生成路由清单" > "${BACKUP_DIR}/flask_routes.txt"
import sys
sys.path.insert(0, '/home/user/webapp')
try:
    from app import app
    routes = []
    for rule in app.url_map.iter_rules():
        routes.append(f"{rule.endpoint:50s} {rule.methods:30s} {rule.rule}")
    print("\n".join(sorted(routes)))
except Exception as e:
    print(f"Error: {e}")
PYEOF
echo "   ✅ Flask路由清单"

# 19. 创建系统信息文件
echo "1️⃣9️⃣  生成系统信息..."
cat > "${BACKUP_DIR}/SYSTEM_INFO.txt" << EOF
====================================================
系统备份信息
====================================================
备份时间: $(date '+%Y-%m-%d %H:%M:%S')
备份版本: ${BACKUP_DATE}
源目录: ${SOURCE_DIR}

====================================================
Python环境
====================================================
Python版本: $(python3 --version)
Pip版本: $(pip3 --version)

已安装的包（主要）:
$(pip3 list | grep -E "Flask|requests|pandas|numpy|pytz" || echo "N/A")

====================================================
Node.js环境
====================================================
Node版本: $(node --version 2>/dev/null || echo "未安装")
NPM版本: $(npm --version 2>/dev/null || echo "未安装")

====================================================
PM2服务状态
====================================================
$(pm2 list 2>/dev/null || echo "PM2未运行")

====================================================
系统版本
====================================================
OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
Kernel: $(uname -r)

====================================================
磁盘使用
====================================================
$(df -h ${SOURCE_DIR})

====================================================
目录结构
====================================================
$(tree -L 2 -d ${SOURCE_DIR} 2>/dev/null || ls -la ${SOURCE_DIR})

====================================================
备份内容统计
====================================================
Python文件: $(find ${SOURCE_DIR} -name "*.py" | wc -l) 个
HTML模板: $(find ${SOURCE_DIR} -name "*.html" | wc -l) 个
Markdown文档: $(find ${SOURCE_DIR} -name "*.md" | wc -l) 个
配置文件: ${CONFIG_COUNT} 个
PM2配置: ${PM2_COUNT} 个

====================================================
EOF
echo "   ✅ 系统信息文件"

# 20. 创建重新部署说明
echo "2️⃣0️⃣  生成重新部署说明..."
cat > "${BACKUP_DIR}/DEPLOYMENT_GUIDE.md" << 'EOF'
# 系统重新部署完整指南

## 📋 前置要求

### 系统环境
- **操作系统**: Ubuntu 20.04+ / Debian 11+
- **Python**: 3.8+
- **Node.js**: 14+
- **PM2**: 最新版本
- **Git**: 2.0+

### 必需软件安装
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装Python和pip
sudo apt install python3 python3-pip python3-venv -y

# 安装Node.js和npm
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install nodejs -y

# 安装PM2
sudo npm install -g pm2

# 安装Git
sudo apt install git -y

# 安装其他工具
sudo apt install rsync tree jq curl wget -y
```

---

## 🚀 部署步骤

### 1. 解压备份文件
```bash
# 解压到目标目录
cd /home/user
tar -xzf /tmp/webapp_complete_backup_YYYYMMDD_HHMMSS.tar.gz
mv webapp_complete_backup_YYYYMMDD_HHMMSS webapp

# 进入目录
cd /home/user/webapp
```

### 2. 安装Python依赖
```bash
# 创建虚拟环境（可选）
python3 -m venv venv
source venv/bin/activate

# 安装依赖
pip3 install -r requirements.txt

# 如果没有requirements.txt，手动安装主要包
pip3 install flask requests pandas numpy pytz python-dotenv
```

### 3. 安装Node.js依赖（如果有）
```bash
# 如果有package.json
npm install

# 或手动安装PM2
npm install -g pm2
```

### 4. 配置环境变量
```bash
# 编辑.env文件
nano .env

# 必需的环境变量：
# TG_BOT_TOKEN=your_telegram_bot_token
# TG_CHAT_ID=your_telegram_chat_id
# OKX_API_KEY=your_okx_api_key
# OKX_SECRET_KEY=your_okx_secret_key
# OKX_PASSPHRASE=your_okx_passphrase
```

### 5. 启动Flask应用
```bash
# 使用PM2启动
pm2 start app.py --name flask-app --interpreter python3

# 或手动启动（调试）
python3 app.py
```

### 6. 启动所有采集器和监控器
```bash
# 方法1: 使用PM2配置文件批量启动
pm2 start ecosystem.config.js

# 方法2: 逐个启动（如果有多个配置文件）
for config in ecosystem.config*.js; do
    pm2 start "$config"
done

# 方法3: 恢复PM2配置
pm2 resurrect
```

### 7. 验证服务状态
```bash
# 查看所有服务
pm2 list

# 查看日志
pm2 logs

# 查看特定服务
pm2 logs flask-app
```

### 8. 配置PM2开机自启
```bash
# 保存当前PM2配置
pm2 save

# 生成启动脚本
pm2 startup

# 执行输出的命令（通常需要sudo）
```

---

## 📂 目录结构说明

```
/home/user/webapp/
├── app.py                          # 主Flask应用
├── requirements.txt                # Python依赖
├── package.json                    # Node.js依赖
├── .env                            # 环境变量
│
├── source_code/                    # 源代码目录
│   ├── *_collector.py              # 数据采集器
│   ├── *_monitor.py                # 监控脚本
│   └── ...
│
├── scripts/                        # 脚本目录
│   ├── *.py                        # Python脚本
│   └── *.sh                        # Shell脚本
│
├── templates/                      # HTML模板
│   └── *.html
│
├── static/                         # 静态资源
│   ├── css/
│   ├── js/
│   └── images/
│
├── data/                           # 数据目录
│   ├── coin_change_tracker/        # 币种数据
│   ├── sar_jsonl/                  # SAR数据
│   ├── positive_ratio_monitor/     # 正数占比监控
│   └── ...
│
├── panic_paged_v2/                 # Panic分页系统V2
├── panic_v3/                       # Panic系统V3
├── major-events-system/            # 重大事件系统
│
├── configs/                        # 配置文件（备份目录）
│   ├── *.json
│   ├── ecosystem.config*.js        # PM2配置
│   └── pm2_dump.pm2
│
└── docs/                           # 文档（备份目录）
    └── *.md
```

---

## 🔧 服务对应关系

### Flask应用
- **服务名**: flask-app
- **文件**: app.py
- **端口**: 9002
- **启动**: `pm2 start app.py --name flask-app --interpreter python3`

### 数据采集器
| 服务名 | 文件 | 功能 | 间隔 |
|--------|------|------|------|
| coin-change-tracker | source_code/coin_change_tracker_collector.py | 27币涨跌幅采集 | 1分钟 |
| sar-slope-collector | source_code/sar_slope_collector.py | SAR指标采集 | 5分钟 |
| signal-collector | source_code/signal_collector.py | 信号数据采集 | 1分钟 |
| liquidation-1h-collector | source_code/liquidation_1h_collector.py | 1小时爆仓数据 | 1小时 |
| ... | ... | ... | ... |

### 监控器
| 服务名 | 文件 | 功能 |
|--------|------|------|
| positive-ratio-monitor | scripts/positive_ratio_monitor.py | 正数占比多空转换监控 |
| five-min-speed-crash-monitor | scripts/five_min_speed_crash_monitor.py | 5分钟涨速暴跌监控 |
| ... | ... | ... |

### 路由映射
- 查看 `flask_routes.txt` 文件获取完整的Flask路由列表

---

## 🔍 验证清单

### 1. 系统环境检查
```bash
python3 --version    # 应该 >= 3.8
node --version       # 应该 >= 14
pm2 --version        # 应该已安装
```

### 2. 服务检查
```bash
pm2 list             # 所有服务应该是 online
pm2 logs --lines 50  # 查看是否有错误
```

### 3. 端口检查
```bash
# 检查Flask端口
curl http://localhost:9002/

# 检查其他端口
netstat -tlnp | grep LISTEN
```

### 4. 数据目录检查
```bash
# 检查数据目录权限
ls -la data/

# 检查数据文件
ls -lh data/coin_change_tracker/
```

### 5. API测试
```bash
# 测试主要API
curl http://localhost:9002/api/coin-change-tracker/latest
curl http://localhost:9002/api/sar-slope/bias-trend
curl http://localhost:9002/api/coin-change-tracker/positive-ratio-stats
```

---

## ⚠️ 常见问题

### 问题1: 权限不足
```bash
# 修改目录权限
sudo chown -R $USER:$USER /home/user/webapp
chmod -R 755 /home/user/webapp
```

### 问题2: Python依赖缺失
```bash
# 逐个安装缺失的包
pip3 install package_name
```

### 问题3: PM2服务启动失败
```bash
# 查看详细错误
pm2 logs service-name --err --lines 100

# 尝试手动启动检查错误
python3 source_code/xxx_collector.py
```

### 问题4: 端口被占用
```bash
# 查找占用端口的进程
lsof -i :9002

# 杀死进程
kill -9 <PID>
```

---

## 📞 技术支持

如果遇到部署问题，请检查：
1. `SYSTEM_INFO.txt` - 系统信息
2. `flask_routes.txt` - Flask路由列表
3. PM2日志: `pm2 logs`
4. Flask日志: 在应用目录查找 `*.log` 文件

---

**文档版本**: 1.0  
**最后更新**: 2026-03-07
EOF
echo "   ✅ 重新部署说明"

# 压缩备份
echo ""
echo "======================================================"
echo "📦 压缩备份文件..."
echo "======================================================"
cd /tmp
tar -czf "${BACKUP_FILE}" "${BACKUP_NAME}"

# 计算大小
BACKUP_SIZE=$(du -sh "${BACKUP_FILE}" | cut -f1)

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
echo "🔍 备份内容验证:"
tar -tzf "${BACKUP_FILE}" | head -20
echo "..."
echo "总计文件数: $(tar -tzf "${BACKUP_FILE}" | wc -l)"
echo ""
echo "======================================================"
echo "📋 使用方法:"
echo "======================================================"
echo "1. 解压: tar -xzf ${BACKUP_FILE}"
echo "2. 阅读: cat webapp_complete_backup_*/DEPLOYMENT_GUIDE.md"
echo "3. 部署: 按照DEPLOYMENT_GUIDE.md中的步骤操作"
echo "======================================================"
