# ⚡ 5分钟涨速止盈系统使用指南

## 📅 更新日期
**2026-03-07 04:00 CST**

## 🎯 系统概述

基于5分钟涨速的自动止盈系统。监控当天最高/最低涨速，在超过设定阈值时自动平仓。

### 核心逻辑
- **最高涨速 > 多单止盈阈值** → 🟢 平掉所有多单（市场过热止盈）
- **最低涨速 < 空单止盈阈值** → 🔴 平掉所有空单（市场过冷止盈）

### 权限管理
- **触发后锁定**: 执行止盈后自动锁定 `allow_execute = false`
- **手动重置**: 需要手动调用重置API才能再次执行
- **防止重复**: 避免同一行情多次触发止盈

## 🔧 后端API

### 1. 配置管理 API

#### 获取配置
```bash
GET /api/okx-trading/velocity-takeprofit/config/<account_id>
```

**返回示例:**
```json
{
  "success": true,
  "config": {
    "enabled": false,
    "long_threshold": 15.0,
    "short_threshold": -15.0,
    "allow_execute": true,
    "last_check_time": null,
    "current_velocity": null,
    "max_velocity": null,
    "min_velocity": null
  }
}
```

#### 保存配置
```bash
POST /api/okx-trading/velocity-takeprofit/config/<account_id>
Content-Type: application/json

{
  "enabled": true,
  "long_threshold": 15.0,
  "short_threshold": -15.0
}
```

### 2. 检查并执行 API

```bash
POST /api/okx-trading/velocity-takeprofit/check/<account_id>
```

**返回示例 (触发多单止盈):**
```json
{
  "success": true,
  "trigger": true,
  "action": "close_long",
  "current_velocity": 12.5,
  "max_velocity": 16.8,
  "min_velocity": -5.2,
  "long_threshold": 15.0,
  "short_threshold": -15.0,
  "reason": "最高涨速 16.80% > 15.0%，平掉所有多单 (已锁定执行权限，需手动重置)",
  "config": {
    "enabled": true,
    "allow_execute": false,
    "last_check_time": "2026-03-07 04:00:00"
  }
}
```

**action类型:**
- `"close_long"` - 平掉所有多单（最高涨速超过阈值）
- `"close_short"` - 平掉所有空单（最低涨速低于阈值）
- `"none"` - 无操作

### 3. 重置执行权限 API

```bash
POST /api/okx-trading/velocity-takeprofit/reset-permission/<account_id>
```

**返回示例:**
```json
{
  "success": true,
  "message": "执行权限已重置",
  "config": {
    "enabled": true,
    "allow_execute": true,
    "long_threshold": 15.0,
    "short_threshold": -15.0
  }
}
```

### 4. 历史记录 API

```bash
GET /api/okx-trading/velocity-takeprofit/history/<account_id>
```

**返回示例:**
```json
{
  "success": true,
  "history": [
    {
      "timestamp": "2026-03-07 04:00:00",
      "action": "config_update",
      "enabled": true,
      "long_threshold": 15.0,
      "short_threshold": -15.0,
      "allow_execute": true
    },
    {
      "timestamp": "2026-03-07 04:05:30",
      "action": "check",
      "trigger": true,
      "close_action": "close_long",
      "current_velocity": 12.5,
      "max_velocity": 16.8,
      "min_velocity": -5.2,
      "reason": "最高涨速 16.80% > 15.0%，平掉所有多单"
    },
    {
      "timestamp": "2026-03-07 04:10:00",
      "action": "reset_permission",
      "allow_execute": true
    }
  ]
}
```

## 💾 数据存储

### 配置文件
```
data/velocity_takeprofit/{account_id}_config.json
```

**文件内容:**
```json
{
  "enabled": true,
  "long_threshold": 15.0,
  "short_threshold": -15.0,
  "allow_execute": false,
  "last_check_time": "2026-03-07 04:05:30",
  "current_velocity": 12.5,
  "max_velocity": 16.8,
  "min_velocity": -5.2
}
```

### 历史记录
```
data/velocity_takeprofit/{account_id}_history.jsonl
```

**JSONL格式:**
```jsonl
{"timestamp": "2026-03-07 04:00:00", "action": "config_update", "enabled": true, "long_threshold": 15.0}
{"timestamp": "2026-03-07 04:05:30", "action": "check", "trigger": true, "close_action": "close_long"}
{"timestamp": "2026-03-07 04:10:00", "action": "reset_permission", "allow_execute": true}
```

## 🎛️ 配置参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| **enabled** | boolean | false | 是否启用策略 |
| **long_threshold** | float | 15.0 | 多单止盈阈值（最高涨速 > 此值平多单）|
| **short_threshold** | float | -15.0 | 空单止盈阈值（最低涨速 < 此值平空单）|
| **allow_execute** | boolean | true | 执行权限（触发后自动设为false）|
| **last_check_time** | string | null | 上次检查时间 |
| **current_velocity** | float | null | 当前5分钟涨速 |
| **max_velocity** | float | null | 当天最高涨速 |
| **min_velocity** | float | null | 当天最低涨速 |

## 🔄 执行流程

### 1. 初始化配置
```bash
# 查看默认配置
curl http://localhost:9002/api/okx-trading/velocity-takeprofit/config/main
```

### 2. 启用策略并设置阈值
```bash
curl -X POST http://localhost:9002/api/okx-trading/velocity-takeprofit/config/main \
  -H 'Content-Type: application/json' \
  -d '{
    "enabled": true,
    "long_threshold": 15.0,
    "short_threshold": -15.0
  }'
```

### 3. 定时检查（前端实现）
```javascript
// 每30秒检查一次
setInterval(async () => {
  const response = await fetch('/api/okx-trading/velocity-takeprofit/check/main', {
    method: 'POST'
  });
  const result = await response.json();
  
  if (result.trigger) {
    console.log('🚨 触发止盈:', result.action);
    console.log('原因:', result.reason);
    
    // 执行相应的平仓操作
    if (result.action === 'close_long') {
      await closeAllAccountsPositions('long');  // 平多单
    } else if (result.action === 'close_short') {
      await closeAllAccountsPositions('short'); // 平空单
    }
    
    // 提示用户需要重置权限
    alert('止盈已执行，需要手动重置执行权限才能再次触发');
  }
}, 30000);
```

### 4. 重置执行权限
```bash
curl -X POST http://localhost:9002/api/okx-trading/velocity-takeprofit/reset-permission/main
```

### 5. 查看历史
```bash
curl http://localhost:9002/api/okx-trading/velocity-takeprofit/history/main
```

## 📊 权限状态机

```
初始状态: allow_execute = true
         |
         | 启用策略 (enabled = true)
         v
   ┌──────────────┐
   │   监控中     │ 实时检查最高/最低涨速
   │ (允许执行)   │
   └──────────────┘
         |
         | 触发条件满足
         v
   ┌──────────────┐
   │  执行止盈    │ action: close_long/close_short
   │              │
   └──────────────┘
         |
         | 自动锁定权限
         v
   ┌──────────────┐
   │   已锁定     │ allow_execute = false
   │ (禁止执行)   │ 需要手动重置
   └──────────────┘
         |
         | 手动调用 reset-permission API
         v
   ┌──────────────┐
   │  权限重置    │ allow_execute = true
   │ (允许执行)   │ 可再次触发
   └──────────────┘
```

## ⚙️ 使用场景

### 场景1: 开多单后设置止盈保护
```bash
# 1. 开了多单，设置止盈阈值为15%
curl -X POST .../config/main -d '{"enabled": true, "long_threshold": 15.0, "short_threshold": -15.0}'

# 2. 系统监控，当最高涨速>15%时自动平多单
# 3. 触发后自动锁定，避免重复平仓
# 4. 手动重置权限后可继续使用
```

### 场景2: 开空单后设置止盈保护
```bash
# 1. 开了空单，设置止盈阈值为-15%
curl -X POST .../config/main -d '{"enabled": true, "long_threshold": 15.0, "short_threshold": -15.0}'

# 2. 系统监控，当最低涨速<-15%时自动平空单
# 3. 触发后锁定权限
```

### 场景3: 调整阈值
```bash
# 根据市场波动调整阈值
# 高波动期: long_threshold=20, short_threshold=-20
# 低波动期: long_threshold=10, short_threshold=-10
curl -X POST .../config/main -d '{"enabled": true, "long_threshold": 20.0, "short_threshold": -20.0}'
```

## 🚨 注意事项

1. **执行权限管理**
   - 触发后自动锁定 `allow_execute = false`
   - 必须手动调用 reset-permission API 重置
   - 防止同一行情多次触发止盈

2. **阈值设置建议**
   - **多单止盈**: 15-20% （市场过热止盈）
   - **空单止盈**: -15% ~ -20% （市场过冷止盈）
   - 根据币种波动性调整

3. **数据源**
   - 调用 `/api/coin-change-tracker/velocity-history` 获取实时数据
   - 依赖27币涨跌幅和5分钟涨速系统
   - 确保数据采集正常运行

4. **账户隔离**
   - 每个 account_id 独立配置
   - 独立的 JSONL 历史记录
   - 支持: main, fangfang12, anchor, poit

5. **触发逻辑**
   - 使用**当天最高/最低涨速**，不是当前涨速
   - 只要超过阈值就触发，无论当前涨速多少
   - 触发后立即锁定权限

## 🔍 故障排查

### 问题1: API返回"配置不存在"
```bash
# 解决：先创建配置
curl -X POST .../config/main -d '{"enabled": false, "long_threshold": 15.0}'
```

### 问题2: 策略未触发
检查清单：
1. ✅ enabled = true?
2. ✅ allow_execute = true? (未被锁定)
3. ✅ 涨速数据正常?
4. ✅ 阈值设置合理?
5. ✅ 前端定时检查在运行?

### 问题3: 触发后无法再次执行
- 原因：执行权限已锁定
- 解决：调用 reset-permission API 重置
```bash
curl -X POST .../reset-permission/main
```

### 问题4: 查看当前涨速和阈值
```bash
# 查看配置（包含当前涨速）
curl http://localhost:9002/api/okx-trading/velocity-takeprofit/config/main | jq '.'
```

## 📊 数据来源

### 5分钟涨速API
```bash
GET /api/coin-change-tracker/velocity-history
```

**返回示例:**
```json
{
  "success": true,
  "data": [
    {
      "time": "10:00:00",
      "velocity_5min": 12.5,
      "cumulative_pct": 3.2
    },
    {
      "time": "10:05:00",
      "velocity_5min": 16.8,
      "cumulative_pct": 4.1
    }
  ]
}
```

### 数据字段说明
- **velocity_5min**: 5分钟涨速（%）
- **max_velocity**: 当天最高涨速
- **min_velocity**: 当天最低涨速
- **current_velocity**: 当前（最新）5分钟涨速

## 📝 开发计划

### ✅ 已完成 (2026-03-07)
- [x] 后端API实现（4个端点）
- [x] 配置管理
- [x] 权限锁定机制
- [x] 历史记录
- [x] JSONL存储
- [x] 使用指南文档

### ⏳ 待实现
- [ ] OKX交易页面UI卡片（放在正数占比下方）
- [ ] 前端JavaScript检查逻辑
- [ ] 自动平仓集成
- [ ] Telegram通知
- [ ] 权限重置按钮UI

## 🔗 相关链接

- **GitHub仓库**: https://github.com/jamesyidc/1122112211110306
- **分支**: deployment/complete-okx-trading-system
- **相关文档**: 
  - POSITIVE_RATIO_STOPLOSS_GUIDE.md (正数占比止盈止损)
  - V3.10_UPDATE_SUMMARY.md (5分钟涨速监控)
  - POSITIVE_RATIO_MONITOR_GUIDE.md (正数占比监控)

---

**文档创建时间**: 2026-03-07 04:00 CST  
**作者**: AI Assistant  
**版本**: 1.0.0
