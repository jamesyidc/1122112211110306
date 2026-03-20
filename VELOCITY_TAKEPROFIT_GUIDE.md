# ⚡ 5分钟涨速止盈系统使用指南

## 📅 更新日期
**2026-03-07 04:00 CST**

## 🎯 系统概述

基于5分钟涨速的最高/最低值自动止盈系统。监控当前5分钟涨速，在达到设定阈值时自动执行止盈操作。

### 核心逻辑
- **当前涨速 > 最高涨速阈值** → 🟢 止盈多单（涨太快，获利了结）
- **当前涨速 < 最低涨速阈值** → 🔴 止盈空单（跌太快，获利了结）

### 权限管理
- 每次触发后，对应的执行权限自动关闭
- 需要手动重置权限才能再次执行
- 防止重复触发，确保每次操作可控

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
    "long_enabled": false,
    "short_enabled": false,
    "max_velocity_threshold": 15.0,
    "min_velocity_threshold": -15.0,
    "long_permission": true,
    "short_permission": true,
    "last_check_time": null
  }
}
```

#### 保存配置
```bash
POST /api/okx-trading/velocity-takeprofit/config/<account_id>
Content-Type: application/json

{
  "long_enabled": true,
  "short_enabled": true,
  "max_velocity_threshold": 15.0,
  "min_velocity_threshold": -15.0
}
```

### 2. 检查并执行 API

```bash
POST /api/okx-trading/velocity-takeprofit/check/<account_id>
```

**返回示例 (触发时):**
```json
{
  "success": true,
  "trigger": true,
  "action": "close_long",
  "current_velocity": 16.5,
  "max_threshold": 15.0,
  "min_threshold": -15.0,
  "long_permission": false,
  "short_permission": true,
  "reason": "5分钟涨速 16.50% > 阈值 15.00%，触发多单止盈",
  "config": {
    "long_enabled": true,
    "short_enabled": true,
    "max_velocity_threshold": 15.0,
    "min_velocity_threshold": -15.0,
    "long_permission": false,
    "short_permission": true,
    "last_check_time": "2026-03-07 04:00:00"
  }
}
```

**action类型:**
- `"close_long"` - 止盈多单
- `"close_short"` - 止盈空单
- `"none"` - 无操作

### 3. 重置权限 API

```bash
POST /api/okx-trading/velocity-takeprofit/reset-permission/<account_id>
Content-Type: application/json

{
  "type": "both"
}
```

**type参数:**
- `"long"` - 仅重置多单权限
- `"short"` - 仅重置空单权限
- `"both"` - 重置所有权限（默认）

**返回示例:**
```json
{
  "success": true,
  "message": "权限已重置: both",
  "config": {
    "long_permission": true,
    "short_permission": true,
    ...
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
      "long_enabled": true,
      "short_enabled": true,
      "max_velocity_threshold": 15.0,
      "min_velocity_threshold": -15.0
    },
    {
      "timestamp": "2026-03-07 04:01:15",
      "action": "check",
      "trigger": true,
      "takeprofit_action": "close_long",
      "current_velocity": 16.5,
      "max_threshold": 15.0,
      "min_threshold": -15.0,
      "reason": "5分钟涨速 16.50% > 阈值 15.00%，触发多单止盈"
    },
    {
      "timestamp": "2026-03-07 04:05:00",
      "action": "reset_permission",
      "reset_type": "long",
      "long_permission": true,
      "short_permission": false
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
  "long_enabled": true,
  "short_enabled": true,
  "max_velocity_threshold": 15.0,
  "min_velocity_threshold": -15.0,
  "long_permission": false,
  "short_permission": true,
  "last_check_time": "2026-03-07 04:00:00"
}
```

### 历史记录
```
data/velocity_takeprofit/{account_id}_history.jsonl
```

**JSONL格式:**
```jsonl
{"timestamp": "2026-03-07 04:00:00", "action": "config_update", "long_enabled": true, "max_velocity_threshold": 15.0}
{"timestamp": "2026-03-07 04:01:15", "action": "check", "trigger": true, "takeprofit_action": "close_long", "current_velocity": 16.5}
{"timestamp": "2026-03-07 04:05:00", "action": "reset_permission", "reset_type": "long"}
```

## 🎛️ 配置参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| **long_enabled** | boolean | false | 多单止盈是否启用 |
| **short_enabled** | boolean | false | 空单止盈是否启用 |
| **max_velocity_threshold** | float | 15.0 | 最高涨速阈值（%）触发多单止盈 |
| **min_velocity_threshold** | float | -15.0 | 最低涨速阈值（%）触发空单止盈 |
| **long_permission** | boolean | true | 多单执行权限 |
| **short_permission** | boolean | true | 空单执行权限 |
| **last_check_time** | string | null | 最后检查时间 |

## 🔄 执行流程

### 1. 初始化配置
```bash
# 查看当前配置
curl http://localhost:9002/api/okx-trading/velocity-takeprofit/config/main
```

### 2. 启用策略并设置阈值
```bash
curl -X POST http://localhost:9002/api/okx-trading/velocity-takeprofit/config/main \
  -H 'Content-Type: application/json' \
  -d '{
    "long_enabled": true,
    "short_enabled": true,
    "max_velocity_threshold": 15.0,
    "min_velocity_threshold": -15.0
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
    console.log('当前涨速:', result.current_velocity);
    
    // 执行止盈操作
    if (result.action === 'close_long') {
      await closeAllAccountsPositions('long');  // 止盈多单
    } else if (result.action === 'close_short') {
      await closeAllAccountsPositions('short'); // 止盈空单
    }
  }
}, 30000);
```

### 4. 重置权限
```bash
# 重置所有权限
curl -X POST http://localhost:9002/api/okx-trading/velocity-takeprofit/reset-permission/main \
  -H 'Content-Type: application/json' \
  -d '{"type": "both"}'

# 仅重置多单权限
curl -X POST http://localhost:9002/api/okx-trading/velocity-takeprofit/reset-permission/main \
  -H 'Content-Type: application/json' \
  -d '{"type": "long"}'
```

### 5. 查看历史
```bash
curl http://localhost:9002/api/okx-trading/velocity-takeprofit/history/main
```

## 📊 触发逻辑图

```
当前5分钟涨速检查
         |
         ├─ > max_threshold (15%) ──> 触发多单止盈 → 关闭long_permission
         |
         ├─ < min_threshold (-15%) ──> 触发空单止盈 → 关闭short_permission
         |
         └─ 在阈值范围内 ──> 不触发

权限状态:
- long_permission = true  → 允许触发多单止盈
- long_permission = false → 已触发，需手动重置
- short_permission = true  → 允许触发空单止盈
- short_permission = false → 已触发，需手动重置
```

## ⚙️ 使用场景

### 场景1: 多单获利了结
```bash
# 1. 开了多单后，启用多单止盈保护
curl -X POST .../config/main -d '{
  "long_enabled": true,
  "max_velocity_threshold": 15.0
}'

# 2. 系统监控，当涨速超过15%时自动止盈多单
# 3. 触发后long_permission变为false
# 4. 手动重置权限才能再次触发
curl -X POST .../reset-permission/main -d '{"type": "long"}'
```

### 场景2: 空单获利了结
```bash
# 1. 开了空单后，启用空单止盈保护
curl -X POST .../config/main -d '{
  "short_enabled": true,
  "min_velocity_threshold": -15.0
}'

# 2. 系统监控，当涨速低于-15%时自动止盈空单
# 3. 触发后short_permission变为false
# 4. 手动重置权限
curl -X POST .../reset-permission/main -d '{"type": "short"}'
```

### 场景3: 双向止盈
```bash
# 同时启用多单和空单止盈
curl -X POST .../config/main -d '{
  "long_enabled": true,
  "short_enabled": true,
  "max_velocity_threshold": 15.0,
  "min_velocity_threshold": -15.0
}'

# 涨速超过15%  → 止盈多单
# 涨速低于-15% → 止盈空单
```

## 🚨 注意事项

1. **权限管理机制**
   - 触发后对应权限自动关闭
   - 必须手动重置才能再次执行
   - 防止短时间内重复触发

2. **阈值设置建议**
   - 多单止盈阈值: 10% ~ 20% (根据市场波动调整)
   - 空单止盈阈值: -10% ~ -20%
   - 阈值设置过低会频繁触发
   - 阈值设置过高可能错过最佳止盈点

3. **数据源**
   - 调用 `/api/coin-change-tracker/velocity-history` 获取实时涨速
   - 依赖27币涨跌幅追踪系统
   - 确保5分钟涨速数据正常采集

4. **账户隔离**
   - 每个account_id独立配置
   - 互不影响
   - 支持: main, fangfang12, anchor, poit

5. **触发优先级**
   - 多单止盈优先于空单止盈检查
   - 一次只能触发一个操作
   - 避免同时平仓冲突

## 🔍 故障排查

### 问题1: API返回"配置不存在"
```bash
# 解决：先创建配置
curl -X POST .../config/main -d '{"long_enabled": false, "short_enabled": false}'
```

### 问题2: 策略未触发
检查清单：
1. ✅ 对应enabled = true?
2. ✅ 对应permission = true?
3. ✅ 当前涨速超过阈值了?
4. ✅ 涨速数据正常?
5. ✅ 前端定时检查在运行?

### 问题3: 触发后仍然可以执行
- 检查permission状态
- 查看历史记录确认是否触发
- 尝试手动重置权限

### 问题4: 权限重置失败
- 确认配置文件存在
- 检查reset_type参数是否正确
- 查看API返回的错误信息

## 📝 开发计划

### ✅ 已完成 (2026-03-07)
- [x] 后端API实现（4个端点）
- [x] 配置管理
- [x] 权限管理机制
- [x] JSONL历史记录
- [x] 独立账户存储

### ⏳ 待实现
- [ ] OKX交易页面UI卡片
- [ ] 前端JavaScript监控逻辑
- [ ] 自动止盈集成
- [ ] 实时涨速显示
- [ ] Telegram通知

## 🔗 相关链接

- **GitHub仓库**: https://github.com/jamesyidc/1122112211110306
- **分支**: deployment/complete-okx-trading-system
- **相关文档**: 
  - POSITIVE_RATIO_STOPLOSS_GUIDE.md (正数占比止盈止损)
  - POSITIVE_RATIO_MONITOR_GUIDE.md (正数占比监控)
  - V3.10_UPDATE_SUMMARY.md (5分钟涨速监控)

## 📊 对比表格

| 系统 | 数据源 | 触发条件 | 操作 | 权限管理 |
|------|--------|----------|------|----------|
| **正数占比止盈止损** | 正数占比40% | 跨越阈值 | 平多单/平空单 | 单次执行 |
| **5分钟涨速止盈** | 5分钟涨速 | 超过阈值 | 止盈多单/止盈空单 | 手动重置 |

---

**文档创建时间**: 2026-03-07 04:00 CST  
**作者**: AI Assistant  
**版本**: 1.0.0
