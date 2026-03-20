# OKX Trading System - 完整部署指南

**版本**: v3.15.1-FULL-BACKUP  
**更新日期**: 2026-03-08  
**备份脚本**: `create_full_backup.sh`

---

## 📋 目录

1. [系统要求](#系统要求)
2. [备份文件结构](#备份文件结构)
3. [部署步骤](#部署步骤)
4. [依赖安装](#依赖安装)
5. [配置说明](#配置说明)
6. [服务启动](#服务启动)
7. [验证测试](#验证测试)
8. [故障排查](#故障排查)
9. [维护命令](#维护命令)

---

## 🖥️ 系统要求

### 操作系统
- **推荐**: Ubuntu 20.04 LTS / Ubuntu 22.04 LTS
- **最低**: Debian 10+ / CentOS 8+

### 硬件要求
```
CPU:    2核+ (推荐4核)
内存:    4GB+ (推荐8GB)
磁盘:    20GB+ (数据目录需要额外空间)
网络:    稳定的互联网连接
```

### 软件依赖
```
Python:   3.8+
Node.js:  14.x+ (推荐18.x)
npm:      6.x+
PM2:      最新版本
Git:      2.x+
```

---

## 📦 备份文件结构

解压 `okx_trading_backup_YYYYMMDD.tar.gz` 后的目录结构：

```
okx_trading_backup_YYYYMMDD/
├── webapp/                          # 应用代码和数据
│   ├── app.py                       # 主Flask应用
│   ├── source_code/                 # Python API文件
│   ├── panic_paged_v2/              # Panic Paged V2系统
│   ├── panic_v3/                    # Panic V3系统
│   ├── major-events-system/         # 重大事件系统
│   ├── scripts/                     # 监控和工具脚本
│   ├── coin_tracker/                # 币种追踪模块
│   ├── tools/                       # 工具模块
│   ├── templates/                   # HTML模板
│   ├── static/                      # 静态资源
│   ├── config/                      # 系统配置
│   ├── data/                        # 数据文件（完整数据）
│   ├── package.json                 # Node.js依赖配置
│   ├── requirements.txt             # Python依赖
│   ├── ecosystem.config.js          # PM2配置
│   └── *.md                         # 文档
├── system_config/                   # 系统配置信息
│   ├── python_packages.txt          # Python包列表
│   ├── apt_packages.txt             # 系统包列表
│   ├── pm2_processes.txt            # PM2进程列表
│   └── dump.pm2                     # PM2进程配置
└── BACKUP_MANIFEST.txt              # 备份清单
```

---

## 🚀 部署步骤

### 步骤 1: 准备服务器环境

```bash
# 1.1 更新系统
sudo apt update && sudo apt upgrade -y

# 1.2 安装基础工具
sudo apt install -y curl wget git vim build-essential

# 1.3 安装Python 3.8+
sudo apt install -y python3 python3-pip python3-venv

# 1.4 验证Python版本
python3 --version  # 应该 >= 3.8
```

### 步骤 2: 安装Node.js和PM2

```bash
# 2.1 安装Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# 2.2 验证安装
node --version   # v18.x.x
npm --version    # 9.x.x

# 2.3 安装PM2全局
sudo npm install -g pm2

# 2.4 设置PM2开机启动
pm2 startup
# 按照输出的命令执行
```

### 步骤 3: 解压备份文件

```bash
# 3.1 上传备份文件到服务器
# scp okx_trading_backup_20260308.tar.gz user@server:/tmp/

# 3.2 解压备份
cd /tmp
tar xzf okx_trading_backup_20260308.tar.gz

# 3.3 创建应用目录
sudo mkdir -p /home/user/webapp
sudo chown -R $USER:$USER /home/user/webapp

# 3.4 复制应用文件
cp -r okx_trading_backup_20260308/webapp/* /home/user/webapp/

# 3.5 设置权限
chmod +x /home/user/webapp/scripts/*.py
```

### 步骤 4: 安装Python依赖

```bash
# 4.1 进入应用目录
cd /home/user/webapp

# 4.2 创建虚拟环境（可选但推荐）
python3 -m venv venv
source venv/bin/activate

# 4.3 升级pip
pip install --upgrade pip

# 4.4 安装依赖
pip install -r requirements.txt

# 4.5 验证关键包
pip list | grep -E "flask|requests|pandas|okx"
```

### 步骤 5: 安装Node.js依赖

```bash
# 5.1 检查package.json
cd /home/user/webapp
cat package.json

# 5.2 安装依赖（如果需要）
# 注意：大多数功能不需要Node.js依赖，PM2除外
# npm install  # 如果有前端依赖

# 5.3 验证安装
# npm list
```

### 步骤 6: 配置系统

```bash
# 6.1 检查配置文件
cd /home/user/webapp/config
ls -la

# 6.2 配置Telegram（如需要）
vim config/configs/telegram_config.json
# 填写bot_token和chat_id

# 6.3 配置OKX API（如需要）
# 配置文件位置：data/okx_auto_strategy/account_*.json
# 配置文件位置：scripts/positive_ratio_auto_close.py (硬编码API密钥)

# 6.4 创建必要的目录
mkdir -p /home/user/webapp/logs
mkdir -p /home/user/webapp/tmp
```

---

## 📦 依赖安装

### Python 关键依赖

```txt
Flask==2.3.0              # Web框架
requests==2.31.0          # HTTP客户端
pandas==2.0.3             # 数据处理
numpy==1.24.3             # 数值计算
python-okx==1.0.0         # OKX API客户端
schedule==1.2.0           # 任务调度
pytz==2023.3              # 时区处理
```

**安装命令**:
```bash
pip install Flask requests pandas numpy python-okx schedule pytz
```

### Node.js 关键依赖

```json
{
  "dependencies": {},
  "devDependencies": {}
}
```

**安装命令**:
```bash
# 通常不需要Node.js依赖，除非有前端构建需求
# npm install
```

### 系统包依赖

```bash
# 基础工具
sudo apt install -y curl wget git vim

# 编译工具
sudo apt install -y build-essential gcc g++ make

# Python开发包
sudo apt install -y python3-dev python3-pip

# 其他工具
sudo apt install -y htop tmux screen
```

---

## ⚙️ 配置说明

### 1. Telegram 配置

文件: `config/configs/telegram_config.json`

```json
{
  "bot_token": "YOUR_BOT_TOKEN",
  "chat_id": "YOUR_CHAT_ID",
  "api_base_url": "https://api.telegram.org",
  "enabled": true
}
```

**获取方式**:
1. 找 @BotFather 创建机器人，获取 `bot_token`
2. 找 @userinfobot 获取你的 `chat_id`

### 2. OKX API 配置

#### 方式一：配置文件（自动策略）

文件: `data/okx_auto_strategy/account_*.json`

```json
{
  "enabled": false,
  "triggerPrice": 66000,
  "strategyType": "bottom_performers",
  "positionSize": 1.5,
  "maxOrderSize": 5.0,
  "apiKey": "YOUR_API_KEY",
  "apiSecret": "YOUR_API_SECRET",
  "passphrase": "YOUR_PASSPHRASE"
}
```

#### 方式二：硬编码（正数占比监控）

文件: `scripts/positive_ratio_auto_close.py`

```python
ACCOUNT_API_KEYS = {
    'account_main': {
        'apiKey': 'YOUR_API_KEY',
        'apiSecret': 'YOUR_API_SECRET',
        'passphrase': 'YOUR_PASSPHRASE'
    },
    # ... 其他账户
}
```

### 3. PM2 配置

文件: `ecosystem.config.js`

```javascript
module.exports = {
  apps: [
    {
      name: 'flask-app',
      script: 'app.py',
      interpreter: 'python3',
      cwd: '/home/user/webapp',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        PORT: 9002,
        FLASK_ENV: 'production'
      }
    }
  ]
};
```

---

## 🎬 服务启动

### 启动顺序

```
1. Flask主应用 (app.py)
   ↓
2. 币种变化追踪器 (coin_change_tracker.py)
   ↓
3. 正数占比监控 (positive_ratio_monitor.py)
   ↓
4. 正数占比自动平仓 (positive_ratio_auto_close.py)
   ↓
5. 其他监控脚本
```

### 启动命令

#### 方式一：使用PM2（推荐）

```bash
# 1. 启动Flask主应用
cd /home/user/webapp
pm2 start app.py --name flask-app --interpreter python3

# 2. 启动币种变化追踪器
pm2 start scripts/coin_change_tracker.py --name coin-change-tracker --interpreter python3

# 3. 启动正数占比监控
pm2 start scripts/positive_ratio_monitor.py --name positive-ratio-monitor --interpreter python3

# 4. 启动正数占比自动平仓
pm2 start scripts/positive_ratio_auto_close.py --name positive-ratio-auto-close --interpreter python3

# 5. 查看所有进程
pm2 list

# 6. 保存PM2配置
pm2 save

# 7. 设置开机启动
pm2 startup
```

#### 方式二：恢复PM2配置

如果备份中包含 `dump.pm2`：

```bash
# 1. 复制PM2配置
cp /tmp/okx_trading_backup_20260308/system_config/dump.pm2 ~/.pm2/

# 2. 恢复进程
pm2 resurrect

# 3. 查看状态
pm2 list
```

#### 方式三：手动启动（调试用）

```bash
# 1. 启动Flask应用
cd /home/user/webapp
python3 app.py &

# 2. 启动币种追踪器
python3 scripts/coin_change_tracker.py &

# 3. 启动正数占比监控
python3 scripts/positive_ratio_monitor.py &

# 4. 启动自动平仓
python3 scripts/positive_ratio_auto_close.py &
```

---

## ✅ 验证测试

### 1. 检查服务状态

```bash
# PM2进程状态
pm2 list

# 应该看到所有进程状态为 "online"
# 示例输出：
# ┌─────┬───────────────────────┬─────────┬─────────┬─────────┐
# │ id  │ name                  │ status  │ restart │ uptime  │
# ├─────┼───────────────────────┼─────────┼─────────┼─────────┤
# │ 0   │ flask-app             │ online  │ 0       │ 5m      │
# │ 1   │ coin-change-tracker   │ online  │ 0       │ 5m      │
# │ 2   │ positive-ratio-monitor│ online  │ 0       │ 5m      │
# │ 3   │ positive-ratio-auto...│ online  │ 0       │ 5m      │
# └─────┴───────────────────────┴─────────┴─────────┴─────────┘
```

### 2. 检查日志

```bash
# 查看Flask应用日志
pm2 logs flask-app --lines 50

# 查看币种追踪器日志
pm2 logs coin-change-tracker --lines 50

# 查看正数占比监控日志
pm2 logs positive-ratio-monitor --lines 50

# 查看自动平仓日志
pm2 logs positive-ratio-auto-close --lines 50
```

### 3. 测试Web界面

```bash
# 检查Flask端口
curl http://localhost:9002/

# 应该返回HTML内容

# 测试API端点
curl http://localhost:9002/api/coin-change-tracker/positive-ratio-stats

# 应该返回JSON数据
```

### 4. 测试正数占比查询

```bash
curl http://localhost:9002/api/coin-change-tracker/positive-ratio-stats

# 预期输出：
# {
#   "success": true,
#   "stats": {
#     "date": "20260308",
#     "positive_count": 63,
#     "total_count": 167,
#     "positive_ratio": 37.72
#   }
# }
```

### 5. 测试账户独立性

```bash
# 检查账户配置
ls -la /home/user/webapp/data/positive_ratio_stoploss/

# 应该看到：
# account_main_config.json
# account_fangfang12_config.json
# account_poit_main_config.json
# account_dadanini_config.json
# account_anchor_config.json

# 查看某个账户配置
cat /home/user/webapp/data/positive_ratio_stoploss/account_poit_main_config.json
```

---

## 🔧 故障排查

### 问题 1: Python依赖安装失败

**症状**: `pip install -r requirements.txt` 报错

**解决方案**:
```bash
# 升级pip
pip install --upgrade pip

# 安装编译工具
sudo apt install -y python3-dev build-essential

# 单独安装失败的包
pip install <package_name> --verbose
```

### 问题 2: PM2进程无法启动

**症状**: `pm2 start` 后进程状态为 "errored"

**解决方案**:
```bash
# 查看详细错误
pm2 logs <app_name> --err --lines 100

# 检查Python路径
which python3

# 手动测试脚本
cd /home/user/webapp
python3 app.py  # 应该能看到Flask启动信息

# 检查文件权限
chmod +x scripts/*.py
```

### 问题 3: 端口冲突

**症状**: Flask启动失败，提示端口被占用

**解决方案**:
```bash
# 查看端口占用
sudo lsof -i :9002

# 杀死占用进程
sudo kill -9 <PID>

# 或修改Flask端口
# 编辑 app.py，修改 app.run(port=9002) 为其他端口
```

### 问题 4: 数据文件缺失

**症状**: 正数占比查询返回空数据

**解决方案**:
```bash
# 检查数据目录
ls -la /home/user/webapp/data/coin_change_tracker/

# 检查币种追踪器是否运行
pm2 logs coin-change-tracker --lines 50

# 手动运行追踪器（调试）
cd /home/user/webapp
python3 scripts/coin_change_tracker.py
```

### 问题 5: Telegram通知不发送

**症状**: 平仓成功但没有收到TG通知

**解决方案**:
```bash
# 检查TG配置
cat /home/user/webapp/config/configs/telegram_config.json

# 测试TG API
curl -X POST "https://api.telegram.org/bot<BOT_TOKEN>/sendMessage" \
  -d "chat_id=<CHAT_ID>" \
  -d "text=Test message"

# 检查脚本日志
pm2 logs positive-ratio-auto-close | grep -i telegram
```

---

## 🛠️ 维护命令

### PM2 管理

```bash
# 查看所有进程
pm2 list

# 查看进程详情
pm2 show <app_name>

# 重启进程
pm2 restart <app_name>

# 停止进程
pm2 stop <app_name>

# 删除进程
pm2 delete <app_name>

# 查看日志
pm2 logs <app_name> --lines 100

# 清空日志
pm2 flush

# 监控
pm2 monit
```

### 数据管理

```bash
# 查看数据目录大小
du -sh /home/user/webapp/data/

# 清理旧日志
find /home/user/webapp/logs -name "*.log" -mtime +7 -delete

# 清理旧数据（保留最近7天）
find /home/user/webapp/data/coin_change_tracker/ -name "*.jsonl" -mtime +7 -delete

# 备份配置文件
cp -r /home/user/webapp/config /home/user/webapp/backups/config_$(date +%Y%m%d)
```

### 系统监控

```bash
# 查看系统资源
htop

# 查看磁盘使用
df -h

# 查看内存使用
free -h

# 查看网络连接
netstat -tuln | grep 9002

# 查看进程CPU/内存
ps aux | grep python3
```

---

## 📊 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                        Nginx (可选)                          │
│                    (反向代理, SSL)                           │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────────────┐
│                   Flask App (Port 9002)                      │
│                   /home/user/webapp/app.py                   │
└──────┬────────────┬────────────┬─────────────┬──────────────┘
       │            │            │             │
       │            │            │             │
┌──────┴──────┐ ┌──┴──────┐ ┌──┴──────┐ ┌────┴────────────┐
│ Coin Change │ │Positive │ │ Positive│ │  其他监控脚本    │
│  Tracker    │ │ Ratio   │ │  Ratio  │ │                  │
│             │ │ Monitor │ │Auto Close│ │                  │
└─────────────┘ └─────────┘ └─────────┘ └──────────────────┘
       │              │            │               │
       │              │            │               │
       ▼              ▼            ▼               ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Files                              │
│         /home/user/webapp/data/                              │
│    ├── coin_change_tracker/                                  │
│    ├── positive_ratio_stoploss/                              │
│    └── okx_auto_strategy/                                    │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔒 安全建议

1. **API密钥安全**
   - 不要将API密钥提交到Git
   - 定期轮换API密钥
   - 使用只读权限的API密钥（如可能）

2. **防火墙配置**
   ```bash
   # 只允许特定IP访问
   sudo ufw allow from <YOUR_IP> to any port 9002
   
   # 启用防火墙
   sudo ufw enable
   ```

3. **Nginx反向代理（推荐）**
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       
       location / {
           proxy_pass http://localhost:9002;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

4. **定期备份**
   ```bash
   # 添加到crontab
   0 2 * * * /home/user/webapp/create_full_backup.sh
   ```

---

## 📞 支持

如有问题，请参考以下文档：

- `VERIFICATION_REPORT.md` - 系统独立性验证报告
- `README.md` - 项目说明
- GitHub Issues: https://github.com/jamesyidc/1122112211110306/issues

---

**文档版本**: v3.15.1  
**最后更新**: 2026-03-08  
**维护者**: AI Assistant
