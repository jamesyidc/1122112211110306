# OKX交易系统完整部署指南

## 📦 备份内容

### 1. 核心应用文件
- Python文件（~88个）：主应用、采集器、监控器、管理器
- 配置文件：JSON、JS、TXT等
- 文档文件：Markdown文档（~440个）
- 脚本文件：Shell脚本

### 2. 目录结构
```
okx_trading_webapp/
├── monitors/          # 监控器模块
├── collectors/        # 数据采集器
├── managers/          # 管理器
├── source_code/       # API源代码
├── panic_paged_v2/    # Panic系统v2
├── panic_v3/          # Panic系统v3
├── major-events-system/ # 重大事件系统
├── utils/             # 工具函数
├── code/              # 代码模块
├── templates/         # HTML模板（~88个）
├── static/            # 静态资源
├── docs/              # 文档目录
├── config/            # 配置目录
├── scripts/           # 脚本目录
├── tests/             # 测试目录
└── data/              # 数据目录（完整历史数据，约800MB）
    ├── coin_change_tracker/    # 币种变化追踪数据
    ├── daily_predictions/      # 每日预测数据
    ├── market_sentiment/       # 市场情绪数据
    ├── positive_ratio_stats/   # 正数占比统计
    └── ...                     # 其他数据目录
```

### 3. 依赖包信息
- `requirements.txt` - Python依赖声明
- `pip_installed_packages.txt` - 当前安装的Python包
- `package.json` - Node.js依赖声明
- `ecosystem.config.js` - PM2进程配置
- `pm2_process_list.json` - PM2进程列表
- `apt_installed_packages.txt` - 系统APT包列表

### 4. 数据文件
- 完整历史数据（非7天限制）
- 数据跨度：2025-12-27 至今
- 数据大小：约800MB（压缩后约256MB）

## 🔧 系统要求

### 操作系统
- Ubuntu 20.04+ / Debian 11+
- CentOS 8+ / RHEL 8+

### 软件依赖
```bash
# Python
Python 3.12+

# Node.js
Node.js 18+
npm 9+

# 系统工具
git
curl
wget
build-essential
```

## 📝 快速部署步骤

### 1. 解压备份
```bash
# 解压到目标目录
tar -xzf okx_trading_webapp_complete_v3_*.tar.gz
cd okx_trading_webapp_complete_v3_*/

# 移动到标准目录（可选）
sudo mv * /home/user/webapp/
cd /home/user/webapp/
```

### 2. 安装系统依赖
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y python3 python3-pip python3-venv \
    nodejs npm git curl wget build-essential

# CentOS/RHEL
sudo yum install -y python3 python3-pip \
    nodejs npm git curl wget gcc gcc-c++ make
```

### 3. 安装Python依赖
```bash
# 使用requirements.txt
pip3 install -r requirements.txt

# 或使用已导出的包列表（精确版本）
pip3 install -r pip_installed_packages.txt
```

### 4. 安装Node.js依赖
```bash
# 安装PM2全局
sudo npm install -g pm2

# 如果有package.json，安装项目依赖
npm install
```

### 5. 配置环境变量
```bash
# 创建.env文件或设置环境变量
export OKX_API_KEY="your_api_key"
export OKX_SECRET_KEY="your_secret_key"
export OKX_PASSPHRASE="your_passphrase"

# 或创建.env文件
cat > .env << EOF
OKX_API_KEY=your_api_key
OKX_SECRET_KEY=your_secret_key
OKX_PASSPHRASE=your_passphrase
