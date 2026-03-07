#!/usr/bin/env python3
"""
5分钟涨速止盈监控器
每30秒检查一次5分钟涨速，触发条件时执行平仓
"""
import sys
import os
import time
import json
import requests
from pathlib import Path
from datetime import datetime

# 添加项目根目录到Python路径
sys.path.insert(0, '/home/user/webapp')

# 配置
ACCOUNTS = [
    'account_main',
    'account_fangfang12', 
    'account_anchor',
    'account_poit'
]

# 账户中文名称映射
ACCOUNT_NAMES = {
    'account_main': '主账户',
    'account_fangfang12': 'Fangfang12',
    'account_anchor': '锚点账号',
    'account_poit': 'POIT'
}

CHECK_INTERVAL = 30  # 检查间隔（秒）
API_BASE_URL = 'http://localhost:9002'

# Telegram配置（从环境变量读取）
TG_BOT_TOKEN = os.getenv('TG_BOT_TOKEN')
TG_CHAT_ID = os.getenv('TG_CHAT_ID')

def log(msg):
    """打印日志"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"[{timestamp}] {msg}", flush=True)

def send_telegram(message):
    """发送Telegram消息"""
    if not TG_BOT_TOKEN or not TG_CHAT_ID:
        log("⚠️ Telegram配置未设置，跳过发送")
        return False
    
    try:
        url = f"https://api.telegram.org/bot{TG_BOT_TOKEN}/sendMessage"
        data = {
            'chat_id': TG_CHAT_ID,
            'text': message,
            'parse_mode': 'HTML'
        }
        
        response = requests.post(url, data=data, timeout=10)
        response.raise_for_status()
        
        log("✅ Telegram消息发送成功")
        return True
        
    except Exception as e:
        log(f"❌ Telegram消息发送失败: {e}")
        return False

def get_velocity_config(account_id):
    """获取账户的涨速止盈配置"""
    try:
        response = requests.get(
            f'{API_BASE_URL}/api/okx-trading/velocity-takeprofit/config/{account_id}',
            timeout=5
        )
        data = response.json()
        if data.get('success'):
            return data.get('config', {})
        return None
    except Exception as e:
        log(f"❌ [{account_id}] 获取配置失败: {e}")
        return None

def get_current_velocity():
    """获取当前5分钟涨速"""
    try:
        response = requests.get(
            f'{API_BASE_URL}/api/coin-change-tracker/velocity-history?limit=1',
            timeout=5
        )
        data = response.json()
        if data.get('success') and data.get('data'):
            latest = data['data'][0]
            return float(latest.get('velocity_5min', 0))
        return 0.0
    except Exception as e:
        log(f"❌ 获取涨速失败: {e}")
        return 0.0

def get_positions(account_id):
    """获取账户持仓"""
    config_file = Path(f'/home/user/webapp/data/okx_auto_strategy/{account_id}.json')
    if not config_file.exists():
        return []
    
    try:
        with open(config_file, 'r') as f:
            account_config = json.load(f)
        
        api_key = account_config.get('api_key')
        api_secret = account_config.get('api_secret')
        passphrase = account_config.get('passphrase')
        
        response = requests.post(
            f'{API_BASE_URL}/api/okx-trading/positions',
            json={
                'api_key': api_key,
                'api_secret': api_secret,
                'passphrase': passphrase
            },
            timeout=10
        )
        
        data = response.json()
        if data.get('success'):
            return data.get('positions', [])
        return []
    except Exception as e:
        log(f"❌ [{account_id}] 获取持仓失败: {e}")
        return []

def close_positions(account_id, positions, side):
    """平仓"""
    config_file = Path(f'/home/user/webapp/data/okx_auto_strategy/{account_id}.json')
    if not config_file.exists():
        return False
    
    try:
        with open(config_file, 'r') as f:
            account_config = json.load(f)
        
        api_key = account_config.get('api_key')
        api_secret = account_config.get('api_secret')
        passphrase = account_config.get('passphrase')
        
        success_count = 0
        for pos in positions:
            if pos.get('posSide') != side:
                continue
            
            inst_id = pos.get('instId')
            pos_size = abs(float(pos.get('pos', 0)))
            
            if pos_size == 0:
                continue
            
            log(f"📤 [{account_id}] 平仓 {inst_id} {side} {pos_size}张")
            
            response = requests.post(
                f'{API_BASE_URL}/api/okx-trading/close-position',
                json={
                    'api_key': api_key,
                    'api_secret': api_secret,
                    'passphrase': passphrase,
                    'inst_id': inst_id,
                    'pos_side': side,
                    'size': str(pos_size)
                },
                timeout=10
            )
            
            result = response.json()
            if result.get('success'):
                log(f"✅ [{account_id}] {inst_id} 平仓成功")
                success_count += 1
            else:
                log(f"❌ [{account_id}] {inst_id} 平仓失败: {result.get('message')}")
        
        return success_count > 0
    except Exception as e:
        log(f"❌ [{account_id}] 平仓异常: {e}")
        return False

def check_account(account_id):
    """检查单个账户"""
    # 获取配置
    config = get_velocity_config(account_id)
    if not config:
        return
    
    long_enabled = config.get('long_enabled', False)
    short_enabled = config.get('short_enabled', False)
    long_permission = config.get('long_permission', False)
    short_permission = config.get('short_permission', False)
    max_threshold = float(config.get('max_velocity_threshold', 15.0))
    min_threshold = float(config.get('min_velocity_threshold', -15.0))
    
    # 获取当前涨速
    current_velocity = get_current_velocity()
    
    log(f"📊 [{account_id}] 当前涨速: {current_velocity:.2f}% | 做多阈值: {max_threshold:.1f}% (启用:{long_enabled}, 权限:{long_permission}) | 做空阈值: {min_threshold:.1f}% (启用:{short_enabled}, 权限:{short_permission})")
    
    # 检查做多止盈
    if long_enabled and long_permission and current_velocity >= max_threshold:
        account_name = ACCOUNT_NAMES.get(account_id, account_id)
        log(f"🎯 [{account_id}] 触发做多止盈: {current_velocity:.2f}% >= {max_threshold:.1f}%")
        positions = get_positions(account_id)
        long_positions = [p for p in positions if p.get('posSide') == 'long']
        
        if long_positions:
            log(f"📈 [{account_id}] 发现 {len(long_positions)} 个多单持仓，准备平仓")
            success = close_positions(account_id, positions, 'long')
            
            # 发送TG通知
            if success:
                position_details = "\n".join([
                    f"  • {p.get('instId')}: {abs(float(p.get('pos', 0)))}张"
                    for p in long_positions
                ])
                message = f"""🎯 <b>5分钟涨速止盈 - 做多平仓</b>

📋 <b>账户</b>: {account_name} ({account_id})
📊 <b>当前涨速</b>: +{current_velocity:.2f}%
⚠️ <b>触发阈值</b>: +{max_threshold:.1f}%
📈 <b>平仓数量</b>: {len(long_positions)}个多单

<b>平仓明细</b>:
{position_details}

⏰ <b>执行时间</b>: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
✅ <b>状态</b>: 平仓成功"""
                send_telegram(message)
        else:
            log(f"⚠️ [{account_id}] 没有多单持仓，跳过")
    
    # 检查做空止盈
    if short_enabled and short_permission and current_velocity <= min_threshold:
        account_name = ACCOUNT_NAMES.get(account_id, account_id)
        log(f"🎯 [{account_id}] 触发做空止盈: {current_velocity:.2f}% <= {min_threshold:.1f}%")
        positions = get_positions(account_id)
        short_positions = [p for p in positions if p.get('posSide') == 'short']
        
        if short_positions:
            log(f"📉 [{account_id}] 发现 {len(short_positions)} 个空单持仓，准备平仓")
            success = close_positions(account_id, positions, 'short')
            
            # 发送TG通知
            if success:
                position_details = "\n".join([
                    f"  • {p.get('instId')}: {abs(float(p.get('pos', 0)))}张"
                    for p in short_positions
                ])
                message = f"""🎯 <b>5分钟涨速止盈 - 做空平仓</b>

📋 <b>账户</b>: {account_name} ({account_id})
📊 <b>当前涨速</b>: {current_velocity:.2f}%
⚠️ <b>触发阈值</b>: {min_threshold:.1f}%
📉 <b>平仓数量</b>: {len(short_positions)}个空单

<b>平仓明细</b>:
{position_details}

⏰ <b>执行时间</b>: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
✅ <b>状态</b>: 平仓成功"""
                send_telegram(message)
        else:
            log(f"⚠️ [{account_id}] 没有空单持仓，跳过")

def main():
    """主循环"""
    log("🚀 5分钟涨速止盈监控器启动")
    log(f"📋 监控账户: {', '.join(ACCOUNTS)}")
    log(f"⏰ 检查间隔: {CHECK_INTERVAL}秒")
    log("=" * 60)
    
    while True:
        try:
            log("\n🔄 开始检查...")
            
            for account_id in ACCOUNTS:
                try:
                    check_account(account_id)
                except Exception as e:
                    log(f"❌ [{account_id}] 检查异常: {e}")
            
            log(f"\n⏰ 等待 {CHECK_INTERVAL} 秒后继续...")
            time.sleep(CHECK_INTERVAL)
            
        except KeyboardInterrupt:
            log("\n👋 监控器已停止")
            break
        except Exception as e:
            log(f"❌ 主循环异常: {e}")
            time.sleep(CHECK_INTERVAL)

if __name__ == '__main__':
    main()
