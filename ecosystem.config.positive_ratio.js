module.exports = {
  apps: [{
    name: 'positive-ratio-monitor',
    script: '/home/user/webapp/scripts/positive_ratio_monitor.py',
    interpreter: 'python3',
    cwd: '/home/user/webapp',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '200M',
    env: {
      TG_BOT_TOKEN: process.env.TG_BOT_TOKEN,
      TG_CHAT_ID: process.env.TG_CHAT_ID,
      PYTHONUNBUFFERED: '1'
    },
    error_file: '/home/user/.pm2/logs/positive-ratio-monitor-error.log',
    out_file: '/home/user/.pm2/logs/positive-ratio-monitor-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss',
    merge_logs: true,
    min_uptime: '10s',
    max_restarts: 10,
    restart_delay: 5000
  }]
};
