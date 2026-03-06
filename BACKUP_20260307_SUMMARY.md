# 📦 完整系统备份摘要 - 2026年3月7日

## 📅 备份信息

- **备份日期（北京时间）**: 2026-03-07 03:21:06 CST
- **备份文件**: `/tmp/webapp_full_backup_20260307_032106.tar.gz`
- **压缩大小**: 291 MB
- **原始大小**: ~3.2 GB
- **文件总数**: 5,743 个

## 📊 文件清单

| 文件类型 | 数量 | 说明 |
|---------|------|------|
| Python文件 | 166 | 包含app.py、API、工具脚本等 |
| 脚本文件 | 30 | 采集器、监控器、管理脚本 |
| HTML模板 | 136 | Web界面模板文件 |
| 静态资源 | 40 | CSS、JavaScript、图片等 |
| 配置文件 | 2,416 | JSON、PM2配置、.git等 |
| Markdown文档 | 233 | 系统文档、API文档、指南 |
| 数据文件 | 2,310 | JSONL数据文件（~3.1GB） |
| **总计** | **5,743** | **完整项目备份** |

## 📂 备份结构

```
webapp_full_backup_20260307_032106/
├── code/                      # 所有代码文件 (166个Python文件)
│   ├── app.py                # Flask主应用
│   ├── *.py                  # 根目录Python文件
│   ├── source_code/          # API源代码目录
│   ├── panic_paged_v2/       # Panic系统V2
│   ├── panic_v3/             # Panic系统V3
│   └── major-events-system/  # 重大事件系统（如存在）
├── scripts/                   # 脚本文件 (30个)
│   ├── coin_change_tracker_collector.py
│   ├── five_min_speed_crash_monitor.py
│   ├── positive_ratio_monitor.py
│   └── ...
├── templates/                 # HTML模板 (136个)
│   ├── coin_change_tracker.html
│   ├── sar_bias_trend.html
│   └── ...
├── static/                    # 静态资源 (40个)
│   ├── css/
│   ├── js/
│   └── images/
├── configs/                   # 配置文件 (2,416个)
│   ├── *.json               # JSON配置文件
│   ├── ecosystem.config*.js # PM2服务配置
│   ├── requirements.txt     # Python依赖
│   ├── package.json         # Node.js依赖
│   ├── .env                 # 环境变量
│   └── .git/                # Git仓库 (2,300+文件)
├── docs/                      # 文档 (233个)
│   ├── README.md
│   ├── API文档
│   ├── 系统说明
│   └── 修复报告
├── data/                      # 数据文件 (~3.1GB, 2,310个文件)
│   ├── coin_change_tracker/ # 币种涨跌幅数据
│   ├── sar_jsonl/           # SAR指标数据
│   ├── positive_ratio_monitor/
│   ├── five_min_speed_monitor/
│   └── ...
├── system_info/              # 系统信息
│   ├── pm2_processes.json   # PM2进程配置
│   ├── pm2_dump.pm2         # PM2快照
│   ├── flask_routes.txt     # Flask路由列表
│   ├── pip_packages.txt     # Python包列表
│   ├── apt_packages_*.txt   # APT包列表
│   └── SYSTEM_INFO.txt      # 系统信息
├── DEPLOYMENT_GUIDE.md       # 完整部署指南
├── BACKUP_MANIFEST.md        # 备份清单
└── quick_start.sh            # 快速启动脚本
```

## 🔧 系统配置信息

### PM2服务列表
备份包含完整的PM2服务配置，包括：

1. **flask-app** - Flask主应用 (端口9002)
2. **coin-change-tracker** - 币种涨跌幅采集器
3. **five-min-speed-crash-monitor** - 5分钟涨速监控
4. **positive-ratio-monitor** - 正数占比监控
5. 其他监控和采集服务...

### Flask路由
备份包含完整的Flask路由列表 (`system_info/flask_routes.txt`)，包括：
- API端点配置
- Web界面路由
- 数据接口

### 依赖包
- **Python包**: 见 `system_info/pip_packages.txt`
- **APT包**: 见 `system_info/apt_packages_full.txt`
- **Node包**: 见 `configs/package.json`

## 🚀 快速部署指南

### 1. 解压备份
```bash
cd /tmp
tar -xzf webapp_full_backup_20260307_032106.tar.gz
cd webapp_full_backup_20260307_032106
```

### 2. 查看部署文档
```bash
cat DEPLOYMENT_GUIDE.md
```

### 3. 快速启动（自动化）
```bash
./quick_start.sh
```

### 4. 手动部署步骤

#### a. 复制文件
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
```

#### b. 安装依赖
```bash
cd /home/user/webapp
pip3 install -r requirements.txt
```

#### c. 启动PM2服务
```bash
# 方法1: 使用PM2快照恢复
cp system_info/pm2_dump.pm2 ~/.pm2/dump.pm2
pm2 resurrect

# 方法2: 手动启动
pm2 start app.py --name flask-app --interpreter python3
pm2 start ecosystem.config.coin_change_tracker.js
pm2 start ecosystem.config.five_min_speed.js
pm2 start ecosystem.config.positive_ratio.js
pm2 save
```

#### d. 验证部署
```bash
pm2 list
curl http://localhost:9002/coin-change-tracker
```

## ✅ 验证清单

备份已通过以下关键文件验证：

- ✅ **DEPLOYMENT_GUIDE.md** - 部署指南
- ✅ **BACKUP_MANIFEST.md** - 备份清单
- ✅ **quick_start.sh** - 快速启动脚本
- ✅ **code/app.py** - Flask主应用
- ✅ **system_info/pm2_processes.json** - PM2配置

## 📝 重要说明

1. **数据完整性**: 
   - 包含所有历史数据，非仅7天数据
   - 数据目录大小: ~3.1GB
   - 数据文件数: 2,310个

2. **排除项**:
   - ❌ logs/ 目录（日志文件）
   - ❌ node_modules/ 目录（Node依赖，可重新安装）
   - ❌ backups/ 目录（旧备份）
   - ❌ __pycache__/ 目录（Python缓存）

3. **依赖要求**:
   - Python >= 3.8
   - Node.js (如需npm包)
   - PM2 (服务管理)
   - 磁盘空间: 至少4GB

4. **环境配置**:
   - 检查 `.env` 文件中的环境变量
   - 配置Telegram Bot Token（如需通知功能）
   - 检查端口9002是否可用

## 🔗 相关链接

- **GitHub仓库**: https://github.com/jamesyidc/1122112211110306
- **分支**: deployment/complete-okx-trading-system
- **最新提交**: b7eec68
- **备份脚本**: `create_full_backup_v4.sh`

## 📞 技术支持

如在部署过程中遇到问题：
1. 查看 `DEPLOYMENT_GUIDE.md` 中的故障排查部分
2. 检查 `system_info/` 目录中的系统信息文件
3. 查看PM2日志: `pm2 logs`

## 🎯 备份特性

✅ **使用北京时间** - 文件名使用CST时区，方便识别  
✅ **自动清理旧备份** - 每次执行自动删除旧备份文件  
✅ **完整性验证** - 自动验证关键文件是否包含  
✅ **详细文档** - 包含部署指南、快速启动脚本  
✅ **系统信息导出** - PM2配置、Flask路由、依赖列表  
✅ **数据完整** - 包含所有历史数据，非仅最近数据  

---

**备份生成时间**: 2026-03-07 03:21:06 CST  
**文档创建时间**: 2026-03-07 03:25:00 CST  
**脚本版本**: V4.0
