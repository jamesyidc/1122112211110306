module.exports = {
  apps: [{
    name: 'five-min-speed-crash-monitor',
    script: '/usr/bin/python3',
    args: '/home/user/webapp/scripts/five_min_speed_crash_monitor.py',
    cwd: '/home/user/webapp',
    interpreter: 'none',
    autorestart: true,
    watch: false,
    max_memory_restart: '200M',
    error_file: '/home/user/webapp/logs/five_min_speed_crash_monitor_error.log',
    out_file: '/home/user/webapp/logs/five_min_speed_crash_monitor_out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss',
    merge_logs: true,
    env: {
      PYTHONUNBUFFERED: '1',
      PYTHONPATH: '/home/user/webapp'
    }
  }]
};
