# 正数占比多空转换监控系统 - 完整说明

## 📅 创建时间
**2026-03-07 02:20**

## 📋 功能概述

监控正数占比（27币涨跌幅之和为正的时间占比），当突破40%阈值时自动发送Telegram通知。

### 核心逻辑
- **多空分界线**：40%
- **转多信号**：正数占比从 <40% 上升到 >=40% → 发送TG通知「转多」
- **转空信号**：正数占比从 >=40% 下降到 <40% → 发送TG通知「转空」
- **检查频率**：每60秒检查一次
- **数据来源**：`/api/coin-change-tracker/positive-ratio-stats`

---

## 🎯 使用场景

### 为什么选择40%作为分界线？
正数占比反映市场整体多空力量对比：
- **≥40%**：多头占优，市场偏多，逢低做多
- **<40%**：空头占优，市场偏空，逢高做空

### 信号含义

#### 🟢 转多信号（<40% → >=40%）
```
市场情绪从空头转向多头
操作建议：逢低做多，寻找支撑位入场
```

#### 🔴 转空信号（>=40% → <40%）
```
市场情绪从多头转向空头
操作建议：逢高做空，寻找阻力位入场
```

---

## 🔧 技术实现

### 1. 监控脚本
**位置**：`/home/user/webapp/scripts/positive_ratio_monitor.py`

**核心功能**：
- 每60秒获取最新正数占比数据
- 对比上次状态，判断是否发生多空转换
- 发生转换时发送Telegram通知
- 保存状态和报警历史记录

### 2. PM2配置
**配置文件**：`ecosystem.config.positive_ratio.js`  
**服务名**：`positive-ratio-monitor`  
**PM2 ID**：43  
**状态**：online（自动重启）

### 3. 数据存储
```
/home/user/webapp/data/positive_ratio_monitor/
├── state.json           # 当前状态（最近一次的正数占比和状态）
└── alert_history.json   # 报警历史（最多保留100条）
```

#### state.json 格式
```json
{
  "last_ratio": 46.36,
  "last_status": "bullish",
  "last_check_time": "2026-03-07 02:17:25"
}
```

#### alert_history.json 格式
```json
[
  {
    "time": "2026-03-07 10:30:00",
    "type": "turn_bullish",
    "from_ratio": 38.5,
    "to_ratio": 41.2,
    "from_status": "bearish",
    "to_status": "bullish",
    "threshold": 40.0,
    "data": {
      "ratio": 41.2,
      "positive_count": 45,
      "total_count": 109,
      "date": 20260307,
      "positive_duration": 45.0
    }
  }
]
```

---

## 📱 Telegram通知格式

### 转多信号示例
```
🟢 正数占比多空转换预警！

━━━━━━━━━━━━━━━━━━
📊 转多信号
━━━━━━━━━━━━━━━━━━

📈 正数占比变化: 38.50% → 41.20%
📉 方向: 上升
🔀 状态转换: 🔴 空方 → 🟢 多方

⚡ 阈值: 40.0%
━━━━━━━━━━━━━━━━━━

💡 操作建议: 逢低做多

📊 数据详情:
  • 正数时段: 45/109
  • 正数时长: 45.0 分钟
  • 数据日期: 20260307

⏰ 检查时间: 2026-03-07 10:30:00
```

### 转空信号示例
```
🔴 正数占比多空转换预警！

━━━━━━━━━━━━━━━━━━
📊 转空信号
━━━━━━━━━━━━━━━━━━

📈 正数占比变化: 42.30% → 38.90%
📉 方向: 下降
🔀 状态转换: 🟢 多方 → 🔴 空方

⚡ 阈值: 40.0%
━━━━━━━━━━━━━━━━━━

💡 操作建议: 逢高做空

📊 数据详情:
  • 正数时段: 42/108
  • 正数时长: 42.0 分钟
  • 数据日期: 20260307

⏰ 检查时间: 2026-03-07 14:15:00
```

---

## 🚀 服务管理

### 查看服务状态
```bash
pm2 status positive-ratio-monitor
```

### 查看实时日志
```bash
pm2 logs positive-ratio-monitor
```

### 查看最近日志
```bash
pm2 logs positive-ratio-monitor --lines 100 --nostream
```

### 重启服务
```bash
pm2 restart positive-ratio-monitor
```

### 停止服务
```bash
pm2 stop positive-ratio-monitor
```

### 删除服务
```bash
pm2 delete positive-ratio-monitor
```

---

## 📊 监控示例

### 日志输出示例

#### 启动日志
```
2026-03-07 02:17:25 - INFO - ============================================================
2026-03-07 02:17:25 - INFO - 🚀 正数占比多空转换监控系统启动
2026-03-07 02:17:25 - INFO - ============================================================
2026-03-07 02:17:25 - INFO - ⚙️  配置参数:
2026-03-07 02:17:25 - INFO -    - 多空分界线: 40.0%
2026-03-07 02:17:25 - INFO -    - 检查间隔: 60秒
2026-03-07 02:17:25 - INFO -    - API地址: http://localhost:9002/api/coin-change-tracker/positive-ratio-stats
2026-03-07 02:17:25 - INFO -    - 数据目录: /home/user/webapp/data/positive_ratio_monitor
2026-03-07 02:17:25 - INFO -    - Telegram Bot: ✅ 已配置
2026-03-07 02:17:25 - INFO - ============================================================
```

#### 初始化检查
```
2026-03-07 02:17:25 - INFO - 🔍 执行首次检查（初始化状态）...
2026-03-07 02:17:25 - INFO - ✅ 获取正数占比成功: 46.36%
2026-03-07 02:17:25 - INFO - ✅ 初始状态: 46.36% (bullish)
```

#### 正常监控
```
2026-03-07 02:17:25 - INFO - ============================================================
2026-03-07 02:17:25 - INFO - 🔍 执行第 1 次检查
2026-03-07 02:17:25 - INFO - ============================================================
2026-03-07 02:17:25 - INFO - ✅ 获取正数占比成功: 46.36%
2026-03-07 02:17:25 - INFO - 📊 当前正数占比: 46.36% | 状态: bullish | 阈值: 40.0%
2026-03-07 02:17:25 - INFO - ⏳ 等待 60 秒后进行下次检查...
```

#### 触发报警（转多）
```
2026-03-07 10:30:00 - WARNING - 🔥 检测到转多信号！38.50% → 41.20%
2026-03-07 10:30:00 - INFO - ✅ Telegram消息发送成功
2026-03-07 10:30:00 - INFO - 💾 报警记录已保存
```

#### 触发报警（转空）
```
2026-03-07 14:15:00 - WARNING - 🔥 检测到转空信号！42.30% → 38.90%
2026-03-07 14:15:00 - INFO - ✅ Telegram消息发送成功
2026-03-07 14:15:00 - INFO - 💾 报警记录已保存
```

---

## 📝 查看历史记录

### 查看当前状态
```bash
cat /home/user/webapp/data/positive_ratio_monitor/state.json
```

### 查看报警历史
```bash
cat /home/user/webapp/data/positive_ratio_monitor/alert_history.json | jq '.'
```

### 查看最近10条报警
```bash
cat /home/user/webapp/data/positive_ratio_monitor/alert_history.json | jq '.[-10:]'
```

### 统计报警次数
```bash
cat /home/user/webapp/data/positive_ratio_monitor/alert_history.json | jq 'length'
```

---

## 🔍 调试与测试

### 手动测试API
```bash
curl -s "http://localhost:9002/api/coin-change-tracker/positive-ratio-stats" | jq '.'
```

### 查看当前正数占比
```bash
curl -s "http://localhost:9002/api/coin-change-tracker/positive-ratio-stats" | \
  jq -r '.stats.positive_ratio as $ratio | "当前正数占比: \($ratio)%"'
```

### 修改阈值（需要修改脚本）
编辑 `scripts/positive_ratio_monitor.py`，修改：
```python
THRESHOLD = 40.0  # 改为其他值，如 35.0 或 45.0
```
然后重启服务：
```bash
pm2 restart positive-ratio-monitor
```

---

## ⚙️ 配置参数

在 `scripts/positive_ratio_monitor.py` 中可以调整以下参数：

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `THRESHOLD` | 40.0 | 多空分界线（%） |
| `CHECK_INTERVAL` | 60 | 检查间隔（秒） |
| `API_URL` | http://localhost:9002/api/... | API地址 |

### Telegram配置（环境变量）
```bash
export TG_BOT_TOKEN="your_bot_token"
export TG_CHAT_ID="your_chat_id"
```

---

## 📊 当前状态

### 系统状态
- **服务名**：positive-ratio-monitor
- **PM2 ID**：43
- **状态**：online
- **内存占用**：~7.3 MB
- **自动重启**：✅ 启用

### 初始数据
- **当前正数占比**：46.36%
- **当前状态**：bullish（多头）
- **初始化时间**：2026-03-07 02:17:25
- **触发条件**：当正数占比下降至<40%时，会发送「转空」通知

---

## 🔗 相关链接

- **GitHub仓库**：https://github.com/jamesyidc/1122112211110306
- **分支**：deployment/complete-okx-trading-system
- **提交**：b964bf3
- **Web界面**：https://9002-iq7zoh927x8lpyitg5alc-a402f90a.sandbox.novita.ai/coin-change-tracker

---

## 🎯 使用建议

### 交易策略配合
1. **收到转多信号**：
   - 观察币种涨跌幅分布
   - 寻找回调支撑位
   - 逢低分批建多单

2. **收到转空信号**：
   - 观察币种涨跌幅分布
   - 寻找反弹阻力位
   - 逢高分批建空单

### 注意事项
- ⚠️ 信号仅供参考，需结合其他指标综合判断
- ⚠️ 40%阈值可根据历史数据优化调整
- ⚠️ 建议配合RSI、5分钟涨速等指标使用
- ⚠️ 设置合理的止损和止盈

---

## ✅ 验证步骤

### 1. 验证服务运行
```bash
pm2 status positive-ratio-monitor
# 应该显示 status: online
```

### 2. 验证日志正常
```bash
pm2 logs positive-ratio-monitor --lines 20 --nostream
# 应该看到定期的检查日志
```

### 3. 验证状态文件
```bash
cat /home/user/webapp/data/positive_ratio_monitor/state.json
# 应该显示当前正数占比和状态
```

### 4. 验证API可访问
```bash
curl -s "http://localhost:9002/api/coin-change-tracker/positive-ratio-stats"
# 应该返回正数占比数据
```

---

## 📞 问题排查

### 问题1：服务启动失败
```bash
# 查看错误日志
pm2 logs positive-ratio-monitor --err --lines 50

# 检查Python依赖
python3 -c "import requests"
```

### 问题2：无法获取数据
```bash
# 测试API
curl -v "http://localhost:9002/api/coin-change-tracker/positive-ratio-stats"

# 检查Flask服务
pm2 status flask-app
```

### 问题3：Telegram通知未发送
```bash
# 检查环境变量
echo $TG_BOT_TOKEN
echo $TG_CHAT_ID

# 查看日志中的Telegram错误
pm2 logs positive-ratio-monitor | grep -i telegram
```

---

**文档版本**：v1.0  
**最后更新**：2026-03-07 02:20  
**维护者**：GenSpark AI Developer
