# 📊 正数占比止盈止损系统使用指南

## 📅 更新日期
**2026-03-07 03:30 CST**

## 🎯 系统概述

基于正数占比40%阈值的自动平仓系统。监控27币涨跌幅正数占比，在跨越阈值时自动执行止盈止损。

### 核心逻辑
- **从 <40% 上升至 ≥40%** → 🟢 平掉所有空单（市场转强）
- **从 ≥40% 下降至 <40%** → 🔴 平掉所有多单（市场转弱）

## 🔧 后端API

### 1. 配置管理 API

#### 获取配置
```bash
GET /api/okx-trading/positive-ratio-stoploss/config/<account_id>
```

**返回示例:**
```json
{
  "success": true,
  "config": {
    "enabled": false,
    "threshold": 40.0,
    "last_status": null,
    "last_ratio": null,
    "last_check_time": null,
    "allow_once": true
  }
}
```

#### 保存配置
```bash
POST /api/okx-trading/positive-ratio-stoploss/config/<account_id>
Content-Type: application/json

{
  "enabled": true,
  "threshold": 40.0,
  "allow_once": true
}
```

### 2. 检查并执行 API

```bash
POST /api/okx-trading/positive-ratio-stoploss/check/<account_id>
```

**返回示例 (触发时):**
```json
{
  "success": true,
  "trigger": true,
  "action": "close_short",
  "current_ratio": 42.5,
  "threshold": 40.0,
  "last_status": "below",
  "current_status": "above",
  "reason": "正数占比从 <40.0% 上升至 ≥40.0%，平掉所有空单 (单次执行，已自动关闭策略)",
  "config": {
    "enabled": false,
    "threshold": 40.0,
    "last_status": "above",
    "last_ratio": 42.5,
    "last_check_time": "2026-03-07 03:30:00"
  }
}
```

**action类型:**
- `"close_short"` - 平掉所有空单
- `"close_long"` - 平掉所有多单  
- `"none"` - 无操作

### 3. 历史记录 API

```bash
GET /api/okx-trading/positive-ratio-stoploss/history/<account_id>
```

**返回示例:**
```json
{
  "success": true,
  "history": [
    {
      "timestamp": "2026-03-07 03:30:00",
      "action": "config_update",
      "enabled": true,
      "threshold": 40.0,
      "allow_once": true
    },
    {
      "timestamp": "2026-03-07 03:31:15",
      "action": "check",
      "trigger": true,
      "close_action": "close_short",
      "current_ratio": 42.5,
      "threshold": 40.0,
      "last_status": "below",
      "current_status": "above",
      "reason": "正数占比从 <40.0% 上升至 ≥40.0%，平掉所有空单"
    }
  ]
}
```

## 💾 数据存储

### 配置文件
```
data/positive_ratio_stoploss/{account_id}_config.json
```

**文件内容:**
```json
{
  "enabled": true,
  "threshold": 40.0,
  "last_status": "above",
  "last_ratio": 42.5,
  "last_check_time": "2026-03-07 03:30:00",
  "allow_once": true
}
```

### 历史记录
```
data/positive_ratio_stoploss/{account_id}_history.jsonl
```

**JSONL格式:**
```jsonl
{"timestamp": "2026-03-07 03:30:00", "action": "config_update", "enabled": true, "threshold": 40.0}
{"timestamp": "2026-03-07 03:31:15", "action": "check", "trigger": true, "close_action": "close_short", "current_ratio": 42.5}
```

## 🎛️ 配置参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| **enabled** | boolean | false | 是否启用策略 |
| **threshold** | float | 40.0 | 正数占比阈值（%） |
| **allow_once** | boolean | true | 单次执行模式（触发后自动关闭） |
| **last_status** | string | null | 上次状态 ("above" \| "below" \| null) |
| **last_ratio** | float | null | 上次正数占比值 |
| **last_check_time** | string | null | 上次检查时间 |

## 🔄 执行流程

### 1. 初始化
```bash
# 查看当前配置
curl http://localhost:9002/api/okx-trading/positive-ratio-stoploss/config/main
```

### 2. 启用策略
```bash
curl -X POST http://localhost:9002/api/okx-trading/positive-ratio-stoploss/config/main \
  -H 'Content-Type: application/json' \
  -d '{
    "enabled": true,
    "threshold": 40.0,
    "allow_once": true
  }'
```

### 3. 定时检查（前端实现）
```javascript
// 每30秒检查一次
setInterval(async () => {
  const response = await fetch('/api/okx-trading/positive-ratio-stoploss/check/main', {
    method: 'POST'
  });
  const result = await response.json();
  
  if (result.trigger) {
    console.log('🚨 触发平仓:', result.action);
    console.log('原因:', result.reason);
    
    // 执行相应的平仓操作
    if (result.action === 'close_short') {
      await closeAllAccountsPositions('short'); // 平空单
    } else if (result.action === 'close_long') {
      await closeAllAccountsPositions('long');  // 平多单
    }
  }
}, 30000);
```

### 4. 查看历史
```bash
curl http://localhost:9002/api/okx-trading/positive-ratio-stoploss/history/main
```

## 📊 状态转换图

```
初始状态 (last_status = null)
         |
         | 首次检查，记录当前状态
         v
    +----------+
    |  above   |  (正数占比 >= 40%)
    | (≥40%)   |
    +----------+
         |  ↑
   下降  |  |  上升
         |  |
         v  |
    +----------+
    |  below   |  (正数占比 < 40%)
    | (<40%)   |
    +----------+
```

**触发条件:**
- `below → above`: 触发 `close_short` (平空单)
- `above → below`: 触发 `close_long` (平多单)

## ⚙️ 使用场景

### 场景1: 开空单后设置保护
```bash
# 1. 开了空单后，启用策略保护
curl -X POST .../config/main -d '{"enabled": true, "threshold": 40.0, "allow_once": true}'

# 2. 系统自动监控，当正数占比上升>=40%时自动平空单
# 3. 触发后策略自动关闭（单次执行模式）
```

### 场景2: 开多单后设置止损
```bash
# 1. 开了多单后，启用策略
curl -X POST .../config/main -d '{"enabled": true, "threshold": 40.0, "allow_once": true}'

# 2. 系统自动监控，当正数占比下降<40%时自动平多单
# 3. 触发后策略自动关闭
```

### 场景3: 连续监控模式
```bash
# 设置 allow_once=false，策略不会自动关闭
curl -X POST .../config/main -d '{"enabled": true, "threshold": 40.0, "allow_once": false}'

# 系统持续监控，每次跨越阈值都会触发
```

## 🚨 注意事项

1. **单次执行模式** (allow_once=true)
   - 触发后策略自动禁用
   - 需要手动重新启用
   - 适合单次保护场景

2. **状态跟踪**
   - 只在状态转换时触发（below↔above）
   - 同一状态下不会重复触发
   - 首次检查会记录当前状态但不触发

3. **数据源**
   - 调用 `/api/coin-change-tracker/positive-ratio-stats` 获取实时数据
   - 依赖27币涨跌幅追踪系统
   - 确保数据采集正常运行

4. **账户隔离**
   - 每个account_id独立配置
   - 互不影响
   - 支持: main, fangfang12, anchor, poit

## 🔍 故障排查

### 问题1: API返回"配置不存在"
```bash
# 解决：先创建配置
curl -X POST .../config/main -d '{"enabled": false, "threshold": 40.0}'
```

### 问题2: 策略未触发
检查清单：
1. ✅ enabled = true?
2. ✅ 正数占比数据正常?
3. ✅ 状态发生转换了? (below↔above)
4. ✅ 前端定时检查在运行?

### 问题3: 触发后策略仍然启用
- 检查 `allow_once` 是否为 true
- 查看 `config.enabled` 的当前值
- 检查历史记录确认触发状态

## 📝 开发计划

### ✅ 已完成 (2026-03-07)
- [x] 后端API实现
- [x] 配置管理
- [x] 状态跟踪
- [x] 历史记录
- [x] JSONL存储

### ⏳ 待实现
- [ ] OKX交易页面UI卡片
- [ ] 前端JavaScript检查逻辑
- [ ] 自动平仓集成
- [ ] Telegram通知
- [ ] 可视化仪表板

## 🔗 相关链接

- **GitHub仓库**: https://github.com/jamesyidc/1122112211110306
- **分支**: deployment/complete-okx-trading-system
- **提交**: 1a63093
- **相关文档**: 
  - POSITIVE_RATIO_MONITOR_GUIDE.md (正数占比监控)
  - V3.10_UPDATE_SUMMARY.md (5分钟涨速监控)

---

**文档创建时间**: 2026-03-07 03:35 CST  
**作者**: AI Assistant  
**版本**: 1.0.0
