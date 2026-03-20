module.exports = {
  apps: [{
    name: 'flask-app',
    script: '/home/user/webapp/app.py',
    interpreter: 'python3',
    cwd: '/home/user/webapp',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      PYTHONPATH: '/home/user/webapp',
      PYTHONUNBUFFERED: '1',
      FLASK_APP: 'app.py'
    },
    error_file: '/home/user/.pm2/logs/flask-app-error.log',
    out_file: '/home/user/.pm2/logs/flask-app-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
  }]
};
