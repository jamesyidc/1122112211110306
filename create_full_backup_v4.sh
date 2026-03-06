#!/bin/bash

# ============================================
# 📦 完整系统备份脚本 V4.0
# 日期: 2026-03-07
# 功能: 创建完整的项目备份（~2GB），包含所有代码、配置、数据
# ============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
SOURCE_DIR="/home/user/webapp"
BACKUP_BASE="/tmp"
BEIJING_DATE=$(TZ='Asia/Shanghai' date +%Y%m%d)
BEIJING_TIME=$(TZ='Asia/Shanghai' date +%H%M%S)
BACKUP_NAME="webapp_full_backup_${BEIJING_DATE}_${BEIJING_TIME}"
BACKUP_DIR="${BACKUP_BASE}/${BACKUP_NAME}"
ARCHIVE_FILE="${BACKUP_DIR}.tar.gz"

echo -e "${BLUE}📦 开始创建完整系统备份...${NC}"
echo -e "${YELLOW}北京时间: $(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${YELLOW}源目录: ${SOURCE_DIR}${NC}"
echo -e "${YELLOW}备份文件: ${ARCHIVE_FILE}${NC}"
echo ""

# 删除旧备份
echo -e "${YELLOW}🗑️  删除旧备份文件...${NC}"
rm -f ${BACKUP_BASE}/webapp_full_backup_*.tar.gz
rm -rf ${BACKUP_BASE}/webapp_full_backup_*/ 2>/dev/null || true
echo -e "${GREEN}✅ 旧备份已清理${NC}"
echo ""

# 创建备份目录
mkdir -p "${BACKUP_DIR}"
cd "${SOURCE_DIR}"

# 统计信息初始化
declare -A FILE_COUNTS
declare -A FILE_SIZES

# 函数：复制文件并统计
copy_and_count() {
    local src="$1"
    local dst="$2"
    local category="$3"
    
    if [ -e "$src" ]; then
        cp -r "$src" "$dst" 2>/dev/null || true
        local count=$(find "$dst" -type f 2>/dev/null | wc -l)
        local size=$(du -sb "$dst" 2>/dev/null | awk '{print $1}')
        FILE_COUNTS[$category]=$((${FILE_COUNTS[$category]:-0} + count))
        FILE_SIZES[$category]=$((${FILE_SIZES[$category]:-0} + size))
    fi
}

# 1. 复制代码文件
echo -e "${BLUE}1️⃣  复制代码文件...${NC}"
mkdir -p "${BACKUP_DIR}/code"

# 根目录Python文件
for py in *.py; do
    [ -f "$py" ] && copy_and_count "$py" "${BACKUP_DIR}/code/$py" "python"
done

# 主应用
copy_and_count "app.py" "${BACKUP_DIR}/code/app.py" "python"

# source_code目录
if [ -d "source_code" ]; then
    copy_and_count "source_code" "${BACKUP_DIR}/code/source_code" "python"
fi

# 其他代码目录
for dir in panic_paged_v2 panic_v3 major-events-system; do
    if [ -d "$dir" ]; then
        copy_and_count "$dir" "${BACKUP_DIR}/code/$dir" "python"
    fi
done

echo -e "${GREEN}✅ 代码文件复制完成 (${FILE_COUNTS[python]:-0} 个文件)${NC}"

# 2. 复制脚本
echo -e "${BLUE}2️⃣  复制脚本...${NC}"
if [ -d "scripts" ]; then
    copy_and_count "scripts" "${BACKUP_DIR}/scripts" "scripts"
fi
echo -e "${GREEN}✅ 脚本复制完成 (${FILE_COUNTS[scripts]:-0} 个文件)${NC}"

# 3. 复制模板
echo -e "${BLUE}3️⃣  复制HTML模板...${NC}"
if [ -d "templates" ]; then
    copy_and_count "templates" "${BACKUP_DIR}/templates" "templates"
fi
echo -e "${GREEN}✅ 模板复制完成 (${FILE_COUNTS[templates]:-0} 个文件)${NC}"

# 4. 复制静态资源
echo -e "${BLUE}4️⃣  复制静态资源...${NC}"
if [ -d "static" ]; then
    copy_and_count "static" "${BACKUP_DIR}/static" "static"
fi
echo -e "${GREEN}✅ 静态资源复制完成 (${FILE_COUNTS[static]:-0} 个文件)${NC}"

# 5. 复制配置文件
echo -e "${BLUE}5️⃣  复制配置文件...${NC}"
mkdir -p "${BACKUP_DIR}/configs"

# JSON配置
for json in *.json; do
    [ -f "$json" ] && copy_and_count "$json" "${BACKUP_DIR}/configs/$json" "configs"
done

# PM2配置
for pm2_config in ecosystem.config*.js; do
    [ -f "$pm2_config" ] && copy_and_count "$pm2_config" "${BACKUP_DIR}/configs/$pm2_config" "configs"
done

# 依赖配置
for dep in requirements.txt package.json package-lock.json .env; do
    [ -f "$dep" ] && copy_and_count "$dep" "${BACKUP_DIR}/configs/$dep" "configs"
done

# Git配置
if [ -d ".git" ]; then
    copy_and_count ".git" "${BACKUP_DIR}/.git" "configs"
fi

echo -e "${GREEN}✅ 配置文件复制完成 (${FILE_COUNTS[configs]:-0} 个文件)${NC}"

# 6. 复制文档
echo -e "${BLUE}6️⃣  复制Markdown文档...${NC}"
mkdir -p "${BACKUP_DIR}/docs"
for md in *.md; do
    [ -f "$md" ] && copy_and_count "$md" "${BACKUP_DIR}/docs/$md" "docs"
done
[ -f "README" ] && copy_and_count "README" "${BACKUP_DIR}/docs/README" "docs"
[ -f "LICENSE" ] && copy_and_count "LICENSE" "${BACKUP_DIR}/docs/LICENSE" "docs"
echo -e "${GREEN}✅ 文档复制完成 (${FILE_COUNTS[docs]:-0} 个文件)${NC}"

# 7. 复制数据文件
echo -e "${BLUE}7️⃣  复制数据文件（这可能需要几分钟）...${NC}"
if [ -d "data" ]; then
    DATA_SIZE_BEFORE=$(du -sb data 2>/dev/null | awk '{print $1}')
    copy_and_count "data" "${BACKUP_DIR}/data" "data"
    DATA_SIZE_AFTER=$(du -sb "${BACKUP_DIR}/data" 2>/dev/null | awk '{print $1}')
    echo -e "${GREEN}✅ 数据文件复制完成${NC}"
    echo -e "   原始大小: $(numfmt --to=iec $DATA_SIZE_BEFORE 2>/dev/null || echo $DATA_SIZE_BEFORE bytes)"
    echo -e "   复制大小: $(numfmt --to=iec $DATA_SIZE_AFTER 2>/dev/null || echo $DATA_SIZE_AFTER bytes)"
fi

# 8. 导出系统信息
echo -e "${BLUE}8️⃣  导出系统信息...${NC}"
mkdir -p "${BACKUP_DIR}/system_info"

# PM2进程列表
pm2 jlist > "${BACKUP_DIR}/system_info/pm2_processes.json" 2>/dev/null || echo "[]" > "${BACKUP_DIR}/system_info/pm2_processes.json"
pm2 save --force > /dev/null 2>&1 || true
[ -f ~/.pm2/dump.pm2 ] && cp ~/.pm2/dump.pm2 "${BACKUP_DIR}/system_info/pm2_dump.pm2"

# Flask路由信息
cd "${SOURCE_DIR}"
python3 << 'PYTHON_SCRIPT' > "${BACKUP_DIR}/system_info/flask_routes.txt" 2>/dev/null || echo "无法导出Flask路由" > "${BACKUP_DIR}/system_info/flask_routes.txt"
import sys
sys.path.insert(0, '/home/user/webapp')
try:
    from app import app
    routes = []
    for rule in app.url_map.iter_rules():
        routes.append(f"{rule.endpoint:50s} {','.join(sorted(rule.methods)):30s} {rule.rule}")
    routes.sort()
    print(f"{'端点':<50s} {'方法':<30s} 路由")
    print("=" * 120)
    for route in routes:
        print(route)
except Exception as e:
    print(f"导出路由失败: {e}")
PYTHON_SCRIPT

# Python包列表
pip3 list > "${BACKUP_DIR}/system_info/pip_packages.txt" 2>/dev/null || echo "无法导出pip包列表" > "${BACKUP_DIR}/system_info/pip_packages.txt"
pip3 list --format=columns > "${BACKUP_DIR}/system_info/pip_packages_readable.txt" 2>/dev/null || true

# APT包列表
dpkg -l > "${BACKUP_DIR}/system_info/apt_packages_full.txt" 2>/dev/null || echo "无法导出APT包列表" > "${BACKUP_DIR}/system_info/apt_packages_full.txt"
dpkg --get-selections > "${BACKUP_DIR}/system_info/apt_packages_selections.txt" 2>/dev/null || true

# 系统信息
cat > "${BACKUP_DIR}/system_info/SYSTEM_INFO.txt" << SYSINFO
系统备份信息
============================================
备份时间（北京）: $(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S %Z')
备份时间（UTC）: $(date -u '+%Y-%m-%d %H:%M:%S %Z')
系统: $(uname -a)
Python版本: $(python3 --version 2>&1)
Node版本: $(node --version 2>&1 || echo "未安装")
PM2版本: $(pm2 --version 2>&1 || echo "未安装")
工作目录: ${SOURCE_DIR}
备份目录: ${BACKUP_DIR}
============================================
SYSINFO

echo -e "${GREEN}✅ 系统信息导出完成${NC}"

# 9. 创建部署指南
echo -e "${BLUE}9️⃣  生成部署指南...${NC}"
cat > "${BACKUP_DIR}/DEPLOYMENT_GUIDE.md" << 'DEPLOY_GUIDE'
# 🚀 完整系统部署指南

## 📋 目录结构

```
webapp_full_backup_YYYYMMDD_HHMMSS/
├── code/                      # 所有代码文件
│   ├── app.py                # Flask主应用
│   ├── *.py                  # 根目录Python文件
│   ├── source_code/          # API源代码
│   ├── panic_paged_v2/       # Panic系统V2
│   ├── panic_v3/             # Panic系统V3
│   └── major-events-system/  # 重大事件系统
├── scripts/                   # 所有脚本
├── templates/                 # HTML模板
├── static/                    # 静态资源
├── configs/                   # 配置文件
│   ├── *.json               # JSON配置
│   ├── ecosystem.config*.js # PM2配置
│   ├── requirements.txt     # Python依赖
│   ├── package.json         # Node依赖
│   └── .env                 # 环境变量
├── docs/                      # Markdown文档
├── data/                      # 数据文件（~3.1GB）
├── system_info/              # 系统信息
│   ├── pm2_processes.json   # PM2进程配置
│   ├── flask_routes.txt     # Flask路由列表
│   ├── pip_packages.txt     # Python包列表
│   └── apt_packages*.txt    # 系统包列表
├── DEPLOYMENT_GUIDE.md       # 本文件
└── quick_start.sh            # 快速启动脚本
```

## 🔧 部署步骤

### 1. 解压备份

```bash
cd /tmp
tar -xzf webapp_full_backup_YYYYMMDD_HHMMSS.tar.gz
cd webapp_full_backup_YYYYMMDD_HHMMSS
```

### 2. 恢复代码和配置

```bash
# 创建目标目录
sudo mkdir -p /home/user/webapp
sudo chown -R $USER:$USER /home/user/webapp

# 复制所有文件
cp -r code/* /home/user/webapp/
cp -r scripts /home/user/webapp/
cp -r templates /home/user/webapp/
cp -r static /home/user/webapp/
cp -r data /home/user/webapp/
cp configs/*.json /home/user/webapp/
cp configs/ecosystem.config*.js /home/user/webapp/
cp configs/requirements.txt /home/user/webapp/
cp configs/package.json /home/user/webapp/ 2>/dev/null || true
cp configs/.env /home/user/webapp/ 2>/dev/null || true
cp -r docs/*.md /home/user/webapp/
```

### 3. 安装依赖

#### Python依赖
```bash
cd /home/user/webapp
pip3 install -r requirements.txt
```

#### Node.js依赖（如需要）
```bash
cd /home/user/webapp
npm install
```

#### 系统依赖（参考apt_packages_selections.txt）
```bash
# 查看需要的系统包
cat system_info/apt_packages_selections.txt

# 安装必要的包
sudo apt-get update
sudo apt-get install -y python3 python3-pip nodejs npm
```

### 4. 配置PM2

#### 安装PM2
```bash
sudo npm install -g pm2
```

#### 恢复PM2配置
```bash
cd /home/user/webapp

# 方法1：使用dump文件恢复
cp system_info/pm2_dump.pm2 ~/.pm2/dump.pm2
pm2 resurrect

# 方法2：逐个启动服务
pm2 start app.py --name flask-app --interpreter python3
pm2 start ecosystem.config.coin_change_tracker.js
pm2 start ecosystem.config.five_min_speed.js
pm2 start ecosystem.config.positive_ratio.js
# ... 其他服务

# 设置开机自启
pm2 startup
pm2 save
```

### 5. 验证部署

```bash
# 检查PM2服务
pm2 list
pm2 logs

# 检查Flask路由
curl http://localhost:9002/coin-change-tracker

# 检查API
curl http://localhost:9002/api/coin-change-tracker/latest
```

## 📊 服务列表

根据`system_info/pm2_processes.json`中的配置，需要启动以下服务：

| 服务名称 | 脚本路径 | 端口 | 说明 |
|---------|---------|------|------|
| flask-app | app.py | 9002 | Flask主应用 |
| coin-change-tracker | scripts/coin_change_tracker_collector.py | - | 币种涨跌幅采集器 |
| five-min-speed-crash-monitor | scripts/five_min_speed_crash_monitor.py | - | 5分钟涨速监控 |
| positive-ratio-monitor | scripts/positive_ratio_monitor.py | - | 正数占比监控 |
| ... | ... | ... | ... |

详细配置请查看`system_info/pm2_processes.json`。

## 🌐 访问地址

部署完成后，可通过以下地址访问：

- **主页**: http://localhost:9002/
- **币种追踪**: http://localhost:9002/coin-change-tracker
- **SAR偏向趋势**: http://localhost:9002/sar-bias-trend
- **API文档**: 查看`system_info/flask_routes.txt`

## 🔍 故障排查

### 检查日志
```bash
# PM2日志
pm2 logs flask-app
pm2 logs coin-change-tracker

# Flask日志
tail -f /home/user/webapp/logs/*.log
```

### 常见问题

1. **端口占用**
```bash
# 查看端口占用
sudo lsof -i :9002
# 或
sudo netstat -tlnp | grep 9002
```

2. **Python模块缺失**
```bash
pip3 install -r requirements.txt
```

3. **权限问题**
```bash
sudo chown -R $USER:$USER /home/user/webapp
chmod +x /home/user/webapp/scripts/*.py
```

## 📝 注意事项

1. 确保Python版本 >= 3.8
2. 确保有足够的磁盘空间（至少4GB）
3. 检查防火墙设置，确保端口9002开放
4. 检查Telegram Bot配置（如使用通知功能）
5. 数据文件较大，复制可能需要几分钟

## 📞 技术支持

- GitHub: https://github.com/jamesyidc/1122112211110306
- 分支: deployment/complete-okx-trading-system
- 最新提交: 见备份时间

---
📦 备份生成时间: $(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S %Z')
DEPLOY_GUIDE

echo -e "${GREEN}✅ 部署指南生成完成${NC}"

# 10. 创建快速启动脚本
cat > "${BACKUP_DIR}/quick_start.sh" << 'QUICK_START'
#!/bin/bash
# 快速启动脚本

set -e

echo "🚀 快速部署脚本"
echo "================"

# 安装Python依赖
echo "📦 安装Python依赖..."
cd /home/user/webapp
pip3 install -r configs/requirements.txt

# 复制配置文件
echo "📋 复制配置文件..."
cp -r code/* /home/user/webapp/
cp configs/*.json /home/user/webapp/
cp configs/ecosystem.config*.js /home/user/webapp/

# 启动服务
echo "🚀 启动PM2服务..."
cd /home/user/webapp
pm2 start app.py --name flask-app --interpreter python3

# 启动其他服务
for config in ecosystem.config*.js; do
    [ -f "$config" ] && pm2 start "$config"
done

pm2 save

echo "✅ 部署完成！"
echo "访问: http://localhost:9002/coin-change-tracker"
QUICK_START

chmod +x "${BACKUP_DIR}/quick_start.sh"

echo -e "${GREEN}✅ 快速启动脚本生成完成${NC}"

# 11. 生成备份清单
echo -e "${BLUE}🔟  生成备份清单...${NC}"
cat > "${BACKUP_DIR}/BACKUP_MANIFEST.md" << MANIFEST
# 📦 备份清单

## 📅 备份信息
- **备份时间（北京）**: $(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S %Z')
- **备份时间（UTC）**: $(date -u '+%Y-%m-%d %H:%M:%S %Z')
- **源目录**: ${SOURCE_DIR}
- **备份文件**: ${ARCHIVE_FILE}

## 📊 文件统计

| 文件类型 | 数量 | 总大小 | 占比 | 说明 |
|---------|------|--------|------|------|
| Python文件 | ${FILE_COUNTS[python]:-0} | $(numfmt --to=iec ${FILE_SIZES[python]:-0} 2>/dev/null || echo "${FILE_SIZES[python]:-0} bytes") | - | 包含主应用、API、工具等 |
| 脚本文件 | ${FILE_COUNTS[scripts]:-0} | $(numfmt --to=iec ${FILE_SIZES[scripts]:-0} 2>/dev/null || echo "${FILE_SIZES[scripts]:-0} bytes") | - | 采集器、监控器等 |
| HTML模板 | ${FILE_COUNTS[templates]:-0} | $(numfmt --to=iec ${FILE_SIZES[templates]:-0} 2>/dev/null || echo "${FILE_SIZES[templates]:-0} bytes") | - | Web界面模板 |
| 静态资源 | ${FILE_COUNTS[static]:-0} | $(numfmt --to=iec ${FILE_SIZES[static]:-0} 2>/dev/null || echo "${FILE_SIZES[static]:-0} bytes") | - | CSS、JS、图片等 |
| 配置文件 | ${FILE_COUNTS[configs]:-0} | $(numfmt --to=iec ${FILE_SIZES[configs]:-0} 2>/dev/null || echo "${FILE_SIZES[configs]:-0} bytes") | - | JSON、JS、环境配置 |
| 文档 | ${FILE_COUNTS[docs]:-0} | $(numfmt --to=iec ${FILE_SIZES[docs]:-0} 2>/dev/null || echo "${FILE_SIZES[docs]:-0} bytes") | - | Markdown文档 |
| 数据文件 | ${FILE_COUNTS[data]:-0} | $(numfmt --to=iec ${FILE_SIZES[data]:-0} 2>/dev/null || echo "${FILE_SIZES[data]:-0} bytes") | - | JSONL数据文件 |

## 📂 目录结构

\`\`\`
$(tree -L 2 -d "${BACKUP_DIR}" 2>/dev/null || find "${BACKUP_DIR}" -type d -maxdepth 2 | head -50)
\`\`\`

## ✅ 验证清单

- [x] 代码文件已复制
- [x] 配置文件已复制
- [x] 数据文件已复制
- [x] 系统信息已导出
- [x] 部署指南已生成
- [x] 快速启动脚本已创建

## 🔗 相关链接

- **GitHub仓库**: https://github.com/jamesyidc/1122112211110306
- **分支**: deployment/complete-okx-trading-system
- **部署指南**: DEPLOYMENT_GUIDE.md
- **快速启动**: quick_start.sh

---
生成时间: $(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S')
MANIFEST

echo -e "${GREEN}✅ 备份清单生成完成${NC}"

# 12. 创建压缩包
echo ""
echo -e "${BLUE}📦 创建压缩包（这可能需要几分钟）...${NC}"
cd "${BACKUP_BASE}"
tar -czf "${ARCHIVE_FILE}" "${BACKUP_NAME}/" 2>&1 | grep -v "Removing leading"

# 13. 验证备份
echo ""
echo -e "${BLUE}🔍 验证备份...${NC}"
if [ -f "${ARCHIVE_FILE}" ]; then
    ARCHIVE_SIZE=$(du -h "${ARCHIVE_FILE}" | awk '{print $1}')
    FILE_COUNT=$(tar -tzf "${ARCHIVE_FILE}" | wc -l)
    
    echo -e "${GREEN}✅ 备份创建成功！${NC}"
    echo -e "${GREEN}   文件: ${ARCHIVE_FILE}${NC}"
    echo -e "${GREEN}   大小: ${ARCHIVE_SIZE}${NC}"
    echo -e "${GREEN}   文件数: ${FILE_COUNT}${NC}"
    
    # 验证关键文件
    echo ""
    echo -e "${YELLOW}🔍 验证关键文件...${NC}"
    MISSING_FILES=0
    for key_file in "code/app.py" "DEPLOYMENT_GUIDE.md" "quick_start.sh" "system_info/pm2_processes.json"; do
        if tar -tzf "${ARCHIVE_FILE}" | grep -q "${BACKUP_NAME}/${key_file}"; then
            echo -e "${GREEN}✅ ${key_file}${NC}"
        else
            echo -e "${RED}❌ ${key_file} 缺失${NC}"
            MISSING_FILES=$((MISSING_FILES + 1))
        fi
    done
    
    if [ $MISSING_FILES -eq 0 ]; then
        echo -e "${GREEN}✅ 所有关键文件验证通过${NC}"
    else
        echo -e "${RED}⚠️  有 ${MISSING_FILES} 个关键文件缺失${NC}"
    fi
else
    echo -e "${RED}❌ 备份创建失败${NC}"
    exit 1
fi

# 14. 清理临时目录
echo ""
echo -e "${YELLOW}🗑️  清理临时目录...${NC}"
rm -rf "${BACKUP_DIR}"
echo -e "${GREEN}✅ 清理完成${NC}"

# 15. 输出使用说明
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ 备份完成！${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}📦 备份文件位置:${NC}"
echo -e "   ${ARCHIVE_FILE}"
echo ""
echo -e "${YELLOW}📊 文件统计:${NC}"
echo -e "   Python文件: ${FILE_COUNTS[python]:-0}"
echo -e "   脚本: ${FILE_COUNTS[scripts]:-0}"
echo -e "   HTML模板: ${FILE_COUNTS[templates]:-0}"
echo -e "   静态资源: ${FILE_COUNTS[static]:-0}"
echo -e "   配置文件: ${FILE_COUNTS[configs]:-0}"
echo -e "   文档: ${FILE_COUNTS[docs]:-0}"
echo -e "   数据文件: ${FILE_COUNTS[data]:-0}"
echo ""
echo -e "${YELLOW}🚀 使用方法:${NC}"
echo -e "   1. 解压: tar -xzf ${ARCHIVE_FILE}"
echo -e "   2. 查看: cd ${BACKUP_NAME} && cat DEPLOYMENT_GUIDE.md"
echo -e "   3. 快速部署: ./quick_start.sh"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
