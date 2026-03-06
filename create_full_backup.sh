#!/bin/bash
# 完整系统备份脚本 V3.0 - 包含所有代码、配置、文档、数据、系统信息
# 备份日期: 2026-03-07

set -e

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="webapp_full_backup_${BACKUP_DATE}"
BACKUP_DIR="/tmp/${BACKUP_NAME}"
BACKUP_FILE="/tmp/${BACKUP_NAME}.tar.gz"
SOURCE_DIR="/home/user/webapp"

echo "======================================================"
echo "🚀 完整系统备份 V3.0"
echo "======================================================"
echo "📅 备份时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "📂 源目录: ${SOURCE_DIR}"
echo "💾 备份目录: ${BACKUP_DIR}"
echo "📦 备份文件: ${BACKUP_FILE}"
echo "======================================================"

# 创建备份目录结构
mkdir -p "${BACKUP_DIR}"/{code,configs,docs,data,system_info}

echo ""
echo "📋 第一部分：代码文件备份"
echo "======================================================"

# 1. 根目录Python文件
echo "1️⃣  复制根目录Python文件..."
find "${SOURCE_DIR}" -maxdepth 1 -type f -name "*.py" -exec cp {} "${BACKUP_DIR}/code/" \; 2>/dev/null || true
ROOT_PY_COUNT=$(find "${SOURCE_DIR}" -maxdepth 1 -type f -name "*.py" 2>/dev/null | wc -l)
echo "   ✅ 根目录: ${ROOT_PY_COUNT} 个Python文件"

# 2. app.py（主应用）
echo "2️⃣  复制主应用..."
if [ -f "${SOURCE_DIR}/app.py" ]; then
    cp "${SOURCE_DIR}/app.py" "${BACKUP_DIR}/code/" 2>/dev/null || true
    echo "   ✅ app.py (Flask主应用)"
fi

# 3. source_code/目录
echo "3️⃣  复制 source_code/ 目录..."
if [ -d "${SOURCE_DIR}/source_code" ]; then
    cp -r "${SOURCE_DIR}/source_code" "${BACKUP_DIR}/code/" 2>/dev/null || true
    SC_PY_COUNT=$(find "${SOURCE_DIR}/source_code" -name "*.py" 2>/dev/null | wc -l)
    echo "   ✅ source_code/: ${SC_PY_COUNT} 个Python文件"
fi

# 4. panic_paged_v2/
echo "4️⃣  复制 panic_paged_v2/ 目录..."
if [ -d "${SOURCE_DIR}/panic_paged_v2" ]; then
    cp -r "${SOURCE_DIR}/panic_paged_v2" "${BACKUP_DIR}/code/" 2>/dev/null || true
    PP2_COUNT=$(find "${SOURCE_DIR}/panic_paged_v2" -type f 2>/dev/null | wc -l)
    echo "   ✅ panic_paged_v2/: ${PP2_COUNT} 个文件"
fi

# 5. panic_v3/
echo "5️⃣  复制 panic_v3/ 目录..."
if [ -d "${SOURCE_DIR}/panic_v3" ]; then
    cp -r "${SOURCE_DIR}/panic_v3" "${BACKUP_DIR}/code/" 2>/dev/null || true
    PV3_COUNT=$(find "${SOURCE_DIR}/panic_v3" -type f 2>/dev/null | wc -l)
    echo "   ✅ panic_v3/: ${PV3_COUNT} 个文件"
fi

# 6. major-events-system/
echo "6️⃣  复制 major-events-system/ 目录..."
if [ -d "${SOURCE_DIR}/major-events-system" ]; then
    cp -r "${SOURCE_DIR}/major-events-system" "${BACKUP_DIR}/code/" 2>/dev/null || true
    ME_COUNT=$(find "${SOURCE_DIR}/major-events-system" -type f 2>/dev/null | wc -l)
    echo "   ✅ major-events-system/: ${ME_COUNT} 个文件"
else
    echo "   ⚠️  major-events-system/ 目录不存在"
fi

# 7. scripts/
echo "7️⃣  复制 scripts/ 目录..."
if [ -d "${SOURCE_DIR}/scripts" ]; then
    cp -r "${SOURCE_DIR}/scripts" "${BACKUP_DIR}/code/" 2>/dev/null || true
    SCRIPTS_COUNT=$(find "${SOURCE_DIR}/scripts" -type f 2>/dev/null | wc -l)
    echo "   ✅ scripts/: ${SCRIPTS_COUNT} 个文件"
fi

# 8. templates/
echo "8️⃣  复制 templates/ 目录..."
if [ -d "${SOURCE_DIR}/templates" ]; then
    cp -r "${SOURCE_DIR}/templates" "${BACKUP_DIR}/code/" 2>/dev/null || true
    TPL_COUNT=$(find "${SOURCE_DIR}/templates" -name "*.html" 2>/dev/null | wc -l)
    echo "   ✅ templates/: ${TPL_COUNT} 个HTML文件"
fi

# 9. static/
echo "9️⃣  复制 static/ 目录..."
if [ -d "${SOURCE_DIR}/static" ]; then
    cp -r "${SOURCE_DIR}/static" "${BACKUP_DIR}/code/" 2>/dev/null || true
    STATIC_COUNT=$(find "${SOURCE_DIR}/static" -type f 2>/dev/null | wc -l)
    echo "   ✅ static/: ${STATIC_COUNT} 个文件"
fi

echo ""
echo "📋 第二部分：配置文件备份"
echo "======================================================"

# 10. 所有配置文件
echo "🔟 复制配置文件..."
find "${SOURCE_DIR}" -maxdepth 1 \( -name "*.json" -o -name "*.js" -o -name "*.yaml" -o -name "*.yml" -o -name "*.toml" -o -name "*.ini" \) -exec cp {} "${BACKUP_DIR}/configs/" \; 2>/dev/null || true
CONFIG_COUNT=$(ls "${BACKUP_DIR}/configs" 2>/dev/null | wc -l)
echo "   ✅ 配置文件: ${CONFIG_COUNT} 个"

# 11. ecosystem.config.*.js
echo "1️⃣1️⃣  复制PM2配置..."
find "${SOURCE_DIR}" -maxdepth 1 -name "ecosystem.config*.js" -exec cp {} "${BACKUP_DIR}/configs/" \; 2>/dev/null || true
PM2_CFG_COUNT=$(find "${SOURCE_DIR}" -maxdepth 1 -name "ecosystem.config*.js" 2>/dev/null | wc -l)
echo "   ✅ PM2配置: ${PM2_CFG_COUNT} 个"

# 12. 依赖文件
echo "1️⃣2️⃣  复制依赖文件..."
[ -f "${SOURCE_DIR}/requirements.txt" ] && cp "${SOURCE_DIR}/requirements.txt" "${BACKUP_DIR}/configs/" 2>/dev/null || true
[ -f "${SOURCE_DIR}/package.json" ] && cp "${SOURCE_DIR}/package.json" "${BACKUP_DIR}/configs/" 2>/dev/null || true
[ -f "${SOURCE_DIR}/package-lock.json" ] && cp "${SOURCE_DIR}/package-lock.json" "${BACKUP_DIR}/configs/" 2>/dev/null || true
echo "   ✅ requirements.txt, package.json"

# 13. .env
echo "1️⃣3️⃣  复制环境变量..."
if [ -f "${SOURCE_DIR}/.env" ]; then
    cp "${SOURCE_DIR}/.env" "${BACKUP_DIR}/configs/" 2>/dev/null || true
    echo "   ✅ .env 文件"
fi

# 14. .gitignore
echo "1️⃣4️⃣  复制Git配置..."
[ -f "${SOURCE_DIR}/.gitignore" ] && cp "${SOURCE_DIR}/.gitignore" "${BACKUP_DIR}/configs/" 2>/dev/null || true
if [ -f "${SOURCE_DIR}/.git/config" ]; then
    mkdir -p "${BACKUP_DIR}/configs/git"
    cp "${SOURCE_DIR}/.git/config" "${BACKUP_DIR}/configs/git/" 2>/dev/null || true
fi
echo "   ✅ .gitignore, .git/config"

echo ""
echo "📋 第三部分：文档备份"
echo "======================================================"

# 15. Markdown文档
echo "1️⃣5️⃣  复制Markdown文档..."
find "${SOURCE_DIR}" -maxdepth 1 -name "*.md" -exec cp {} "${BACKUP_DIR}/docs/" \; 2>/dev/null || true
MD_COUNT=$(find "${SOURCE_DIR}" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l)
echo "   ✅ Markdown: ${MD_COUNT} 个"

# 16. README等
echo "1️⃣6️⃣  复制其他文档..."
for file in README* LICENSE* CHANGELOG* CONTRIBUTING*; do
    [ -f "${SOURCE_DIR}/${file}" ] && cp "${SOURCE_DIR}/${file}" "${BACKUP_DIR}/docs/" 2>/dev/null || true
done
echo "   ✅ README, LICENSE等"

echo ""
echo "📋 第四部分：数据备份（排除logs/backups/node_modules/__pycache__）"
echo "======================================================"

# 17. 数据目录
echo "1️⃣7️⃣  复制数据目录（可能需要几分钟）..."
if [ -d "${SOURCE_DIR}/data" ]; then
    echo "   📊 开始复制数据..."
    cd "${SOURCE_DIR}/data"
    
    # 使用find排除不需要的目录
    find . -type d \( -name logs -o -name backups -o -name node_modules -o -name __pycache__ \) -prune -o -type f -print | while read file; do
        target_dir="${BACKUP_DIR}/data/$(dirname "$file")"
        mkdir -p "$target_dir"
        cp "$file" "$target_dir/" 2>/dev/null || true
    done
    
    cd "${SOURCE_DIR}"
    DATA_SIZE=$(du -sh "${BACKUP_DIR}/data" 2>/dev/null | cut -f1)
    DATA_FILES=$(find "${BACKUP_DIR}/data" -type f 2>/dev/null | wc -l)
    echo "   ✅ data/: ${DATA_SIZE} (${DATA_FILES} 个文件)"
fi

echo ""
echo "📋 第五部分：系统信息导出"
echo "======================================================"

# 18. PM2配置导出
echo "1️⃣8️⃣  导出PM2配置..."
pm2 save --force 2>/dev/null || true
if [ -f "$HOME/.pm2/dump.pm2" ]; then
    cp "$HOME/.pm2/dump.pm2" "${BACKUP_DIR}/system_info/pm2_dump.pm2" 2>/dev/null || true
    echo "   ✅ PM2进程列表"
fi

# 导出PM2进程详细信息
pm2 jlist > "${BACKUP_DIR}/system_info/pm2_processes.json" 2>/dev/null || echo "[]" > "${BACKUP_DIR}/system_info/pm2_processes.json"
echo "   ✅ PM2进程详情"

# 19. Flask路由导出
echo "1️⃣9️⃣  导出Flask路由..."
python3 << 'PYEOF' > "${BACKUP_DIR}/system_info/flask_routes.txt" 2>/dev/null || echo "无法生成路由清单" > "${BACKUP_DIR}/system_info/flask_routes.txt"
import sys
sys.path.insert(0, '/home/user/webapp')
try:
    from app import app
    routes = []
    for rule in app.url_map.iter_rules():
        methods = ','.join(sorted(rule.methods - {'HEAD', 'OPTIONS'}))
        routes.append(f"{rule.endpoint:50s} {methods:20s} {rule.rule}")
    print("Flask路由清单")
    print("=" * 100)
    print(f"{'端点名称':<50} {'方法':<20} {'路径'}")
    print("=" * 100)
    for route in sorted(routes):
        print(route)
    print("=" * 100)
    print(f"总计: {len(routes)} 个路由")
except Exception as e:
    print(f"Error: {e}")
PYEOF
echo "   ✅ Flask路由清单"

# 20. Python包列表
echo "2️⃣0️⃣  导出Python包列表..."
pip3 list --format=freeze > "${BACKUP_DIR}/system_info/pip_packages.txt" 2>/dev/null || true
pip3 list > "${BACKUP_DIR}/system_info/pip_packages_readable.txt" 2>/dev/null || true
echo "   ✅ Python包列表"

# 21. APT包列表
echo "2️⃣1️⃣  导出APT包列表..."
dpkg -l > "${BACKUP_DIR}/system_info/apt_packages_full.txt" 2>/dev/null || true
dpkg --get-selections > "${BACKUP_DIR}/system_info/apt_packages_selections.txt" 2>/dev/null || true
echo "   ✅ APT包列表"

# 22. 系统信息
echo "2️⃣2️⃣  生成系统信息..."
cat > "${BACKUP_DIR}/system_info/SYSTEM_INFO.txt" << EOF
====================================================
完整系统备份信息
====================================================
备份时间: $(date '+%Y-%m-%d %H:%M:%S')
备份版本: ${BACKUP_DATE}
源目录: ${SOURCE_DIR}
备份方式: 完整备份（所有数据）

====================================================
Python环境
====================================================
Python版本: $(python3 --version 2>&1)
Pip版本: $(pip3 --version 2>&1)
虚拟环境: $(which python3)

====================================================
Node.js环境
====================================================
Node版本: $(node --version 2>/dev/null || echo "未安装")
NPM版本: $(npm --version 2>/dev/null || echo "未安装")
全局包: $(npm list -g --depth=0 2>/dev/null | wc -l) 个

====================================================
PM2状态
====================================================
$(pm2 list 2>/dev/null || echo "PM2未运行")

====================================================
系统信息
====================================================
操作系统: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown")
内核版本: $(uname -r)
架构: $(uname -m)
主机名: $(hostname)

====================================================
磁盘空间
====================================================
$(df -h ${SOURCE_DIR} 2>/dev/null)

====================================================
备份内容统计
====================================================
根目录Python文件: ${ROOT_PY_COUNT} 个
source_code Python: ${SC_PY_COUNT:-0} 个
panic_paged_v2: ${PP2_COUNT:-0} 个文件
panic_v3: ${PV3_COUNT:-0} 个文件
scripts: ${SCRIPTS_COUNT:-0} 个文件
HTML模板: ${TPL_COUNT:-0} 个
静态资源: ${STATIC_COUNT:-0} 个
配置文件: ${CONFIG_COUNT:-0} 个
PM2配置: ${PM2_CFG_COUNT:-0} 个
Markdown文档: ${MD_COUNT:-0} 个
数据文件: ${DATA_FILES:-0} 个 (${DATA_SIZE:-0})

====================================================
目录大小分布
====================================================
$(du -sh "${BACKUP_DIR}"/* 2>/dev/null | sort -hr)

====================================================
重要文件清单
====================================================
✅ app.py - Flask主应用
✅ requirements.txt - Python依赖
✅ package.json - Node.js依赖
✅ ecosystem.config*.js - PM2配置
✅ .env - 环境变量
✅ source_code/ - API源代码
✅ scripts/ - 脚本文件
✅ templates/ - HTML模板
✅ static/ - 静态资源
✅ data/ - 数据文件
✅ panic_paged_v2/ - Panic系统V2
✅ panic_v3/ - Panic系统V3

====================================================
排除的内容
====================================================
❌ logs/ - 日志文件
❌ node_modules/ - Node依赖包
❌ backups/ - 备份目录
❌ __pycache__/ - Python缓存

====================================================
EOF
echo "   ✅ 系统信息文件"

# 23. 创建详细的部署指南
echo "2️⃣3️⃣  生成部署指南..."
cat > "${BACKUP_DIR}/DEPLOYMENT_GUIDE.md" << 'EOFGUIDE'
# 完整系统重新部署指南

## 📋 目录结构

```
webapp_full_backup_YYYYMMDD_HHMMSS/
├── code/                           # 代码文件
│   ├── *.py                        # 根目录Python文件
│   ├── source_code/                # API源代码
│   ├── panic_paged_v2/             # Panic系统V2
│   ├── panic_v3/                   # Panic系统V3
│   ├── scripts/                    # 脚本文件
│   ├── templates/                  # HTML模板
│   └── static/                     # 静态资源
├── configs/                        # 配置文件
│   ├── ecosystem.config*.js        # PM2配置
│   ├── requirements.txt            # Python依赖
│   ├── package.json                # Node.js依赖
│   ├── .env                        # 环境变量
│   └── *.json                      # 其他配置
├── docs/                           # 文档
│   └── *.md                        # Markdown文档
├── data/                           # 数据文件
│   ├── coin_change_tracker/        # 币种数据
│   ├── sar_jsonl/                  # SAR数据
│   └── ...                         # 其他数据
├── system_info/                    # 系统信息
│   ├── SYSTEM_INFO.txt             # 系统信息摘要
│   ├── flask_routes.txt            # Flask路由清单
│   ├── pm2_dump.pm2                # PM2进程配置
│   ├── pm2_processes.json          # PM2进程详情
│   ├── pip_packages.txt            # Python包列表
│   └── apt_packages_full.txt       # APT包列表
└── DEPLOYMENT_GUIDE.md             # 本文档
```

---

## 🚀 快速部署（5步）

### 1. 解压备份
```bash
cd /home/user
tar -xzf /tmp/webapp_full_backup_*.tar.gz
cd webapp_full_backup_*
```

### 2. 恢复代码
```bash
# 创建目标目录
sudo mkdir -p /home/user/webapp
cd /home/user/webapp

# 复制代码文件
cp -r ../webapp_full_backup_*/code/* .

# 复制配置文件
cp -r ../webapp_full_backup_*/configs/* .

# 复制数据文件
cp -r ../webapp_full_backup_*/data .

# 设置权限
sudo chown -R $USER:$USER /home/user/webapp
chmod -R 755 /home/user/webapp
```

### 3. 安装依赖
```bash
cd /home/user/webapp

# Python依赖
pip3 install -r requirements.txt

# Node.js依赖（如果需要）
npm install
```

### 4. 配置环境变量
```bash
# 编辑.env文件
nano .env

# 必需的环境变量：
# TG_BOT_TOKEN=your_token
# TG_CHAT_ID=your_chat_id
# OKX_API_KEY=your_key
# OKX_SECRET_KEY=your_secret
# OKX_PASSPHRASE=your_passphrase
```

### 5. 启动服务
```bash
# 启动Flask
pm2 start app.py --name flask-app --interpreter python3

# 恢复所有PM2服务
pm2 resurrect

# 或使用配置文件
for cfg in ecosystem.config*.js; do
    pm2 start "$cfg"
done

# 查看状态
pm2 list
pm2 logs
```

---

## 📖 详细部署步骤

### 步骤1: 系统环境准备

#### 1.1 更新系统
```bash
sudo apt update && sudo apt upgrade -y
```

#### 1.2 安装Python 3.8+
```bash
sudo apt install python3 python3-pip python3-venv -y
python3 --version  # 应该 >= 3.8
```

#### 1.3 安装Node.js 14+
```bash
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt install nodejs -y
node --version  # 应该 >= 14
npm --version
```

#### 1.4 安装PM2
```bash
sudo npm install -g pm2
pm2 --version
```

#### 1.5 安装其他工具
```bash
sudo apt install git curl wget jq -y
```

---

### 步骤2: 恢复APT包（可选）

如果需要恢复完全相同的系统包：

```bash
# 查看备份的包列表
cat system_info/apt_packages_selections.txt

# 恢复包（谨慎使用）
# sudo dpkg --set-selections < system_info/apt_packages_selections.txt
# sudo apt-get dselect-upgrade
```

---

### 步骤3: 恢复Python环境

#### 3.1 使用requirements.txt
```bash
cd /home/user/webapp
pip3 install -r requirements.txt
```

#### 3.2 验证关键包
```bash
pip3 list | grep -E "Flask|requests|pandas|pytz"
```

#### 3.3 创建虚拟环境（推荐）
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

### 步骤4: 恢复PM2服务

#### 4.1 方法1：使用pm2 resurrect
```bash
# 复制PM2配置
mkdir -p ~/.pm2
cp system_info/pm2_dump.pm2 ~/.pm2/dump.pm2

# 恢复所有进程
pm2 resurrect
```

#### 4.2 方法2：使用配置文件
```bash
cd /home/user/webapp

# 逐个启动
pm2 start ecosystem.config.js
pm2 start ecosystem.config.positive_ratio.js
pm2 start ecosystem.config.five_min_speed.js
```

#### 4.3 方法3：批量启动
```bash
for cfg in ecosystem.config*.js; do
    echo "启动: $cfg"
    pm2 start "$cfg"
done
```

---

### 步骤5: 验证Flask路由

#### 5.1 查看路由清单
```bash
cat system_info/flask_routes.txt
```

#### 5.2 测试主要路由
```bash
# 测试首页
curl http://localhost:9002/

# 测试API
curl http://localhost:9002/api/coin-change-tracker/latest
curl http://localhost:9002/api/sar-slope/bias-trend
curl http://localhost:9002/api/coin-change-tracker/positive-ratio-stats
```

---

## 🔧 服务对应关系

### Flask应用
```
服务名: flask-app
文件: app.py
端口: 9002
命令: pm2 start app.py --name flask-app --interpreter python3
```

### 数据采集器

| PM2名称 | 文件路径 | 功能 | 间隔 |
|---------|----------|------|------|
| coin-change-tracker | source_code/coin_change_tracker_collector.py | 27币涨跌幅 | 1分钟 |
| sar-slope-collector | source_code/sar_slope_collector.py | SAR指标 | 5分钟 |
| signal-collector | source_code/signal_collector.py | 信号数据 | 1分钟 |
| liquidation-1h-collector | source_code/liquidation_1h_collector.py | 爆仓数据 | 1小时 |
| price-speed-collector | source_code/price_speed_collector.py | 价格速度 | 1分钟 |

### 监控器

| PM2名称 | 文件路径 | 功能 |
|---------|----------|------|
| positive-ratio-monitor | scripts/positive_ratio_monitor.py | 正数占比监控 |
| five-min-speed-crash-monitor | scripts/five_min_speed_crash_monitor.py | 5分钟涨速监控 |
| data-health-monitor | source_code/data_health_monitor.py | 数据健康监控 |

---

## 🔍 验证清单

### ✅ 环境验证
```bash
python3 --version    # >= 3.8
node --version       # >= 14
pm2 --version        # 最新版本
```

### ✅ 服务验证
```bash
pm2 list             # 所有服务online
pm2 logs --lines 50  # 无错误日志
```

### ✅ 端口验证
```bash
netstat -tlnp | grep 9002    # Flask端口
curl http://localhost:9002/  # 返回HTML
```

### ✅ 数据验证
```bash
ls -lh data/coin_change_tracker/
ls -lh data/sar_jsonl/
# 应该有数据文件
```

### ✅ 权限验证
```bash
ls -la /home/user/webapp
# 文件属主应该是当前用户
```

---

## ⚠️ 常见问题

### Q1: 权限不足
```bash
sudo chown -R $USER:$USER /home/user/webapp
chmod -R 755 /home/user/webapp
```

### Q2: Python包缺失
```bash
pip3 install package_name
# 或重新安装所有包
pip3 install -r requirements.txt --force-reinstall
```

### Q3: PM2服务启动失败
```bash
# 查看详细错误
pm2 logs service-name --err --lines 100

# 手动测试
python3 source_code/xxx_collector.py
```

### Q4: 端口被占用
```bash
lsof -i :9002
kill -9 <PID>
```

### Q5: 数据目录不存在
```bash
mkdir -p data/coin_change_tracker
mkdir -p data/sar_jsonl
chmod -R 755 data/
```

---

## 📞 技术支持

### 查看备份信息
```bash
cat system_info/SYSTEM_INFO.txt
```

### 查看Flask路由
```bash
cat system_info/flask_routes.txt
```

### 查看PM2配置
```bash
cat system_info/pm2_processes.json | jq '.'
```

### 查看Python包
```bash
cat system_info/pip_packages.txt
```

---

## 🎯 部署后配置

### PM2开机自启
```bash
pm2 save
pm2 startup
# 执行输出的命令
```

### 日志轮转
```bash
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
```

### 监控设置
```bash
pm2 install pm2-server-monit
```

---

**部署文档版本**: 3.0  
**最后更新**: 2026-03-07  
**适用备份**: webapp_full_backup_*
EOFGUIDE
echo "   ✅ 部署指南"

# 24. 创建快速启动脚本
echo "2️⃣4️⃣  创建快速启动脚本..."
cat > "${BACKUP_DIR}/quick_start.sh" << 'EOFSTART'
#!/bin/bash
# 快速启动脚本

echo "🚀 快速部署脚本"
echo "======================================================"

# 检查Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 未安装"
    exit 1
fi

# 检查PM2
if ! command -v pm2 &> /dev/null; then
    echo "❌ PM2 未安装"
    echo "安装: sudo npm install -g pm2"
    exit 1
fi

# 安装依赖
echo "📦 安装Python依赖..."
pip3 install -r requirements.txt

# 启动Flask
echo "🚀 启动Flask应用..."
pm2 start app.py --name flask-app --interpreter python3

# 启动采集器
echo "📊 启动采集器..."
for cfg in ecosystem.config*.js; do
    pm2 start "$cfg"
done

# 显示状态
echo ""
echo "✅ 部署完成！"
pm2 list

echo ""
echo "======================================================"
echo "📋 访问地址："
echo "   http://localhost:9002"
echo ""
echo "📝 查看日志："
echo "   pm2 logs"
echo "======================================================"
EOFSTART
chmod +x "${BACKUP_DIR}/quick_start.sh"
echo "   ✅ 快速启动脚本"

echo ""
echo "📋 第六部分：压缩备份"
echo "======================================================"

# 压缩
echo "📦 压缩备份文件（这可能需要几分钟）..."
cd /tmp
tar -czf "${BACKUP_FILE}" "${BACKUP_NAME}" 2>&1 | while read line; do
    [ ! -z "$line" ] && echo "   $line"
done || true

BACKUP_SIZE=$(du -sh "${BACKUP_FILE}" 2>/dev/null | cut -f1)

# 清理临时目录
rm -rf "${BACKUP_DIR}"

echo ""
echo "======================================================"
echo "✅ 备份完成！"
echo "======================================================"
echo "📦 备份文件: ${BACKUP_FILE}"
echo "💾 压缩大小: ${BACKUP_SIZE}"
echo "📅 备份时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "🔍 验证备份..."
tar -tzf "${BACKUP_FILE}" 2>/dev/null | head -30
echo "..."
FILE_COUNT=$(tar -tzf "${BACKUP_FILE}" 2>/dev/null | wc -l)
echo "总计: ${FILE_COUNT} 个文件"
echo ""
echo "======================================================"
echo "📋 使用方法："
echo "1. 解压: tar -xzf ${BACKUP_FILE}"
echo "2. 查看: cat */DEPLOYMENT_GUIDE.md"
echo "3. 快速部署: cd */ && ./quick_start.sh"
echo "======================================================"
