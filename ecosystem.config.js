module.exports = {
  apps: [
    {
      name: 'admin-script-web',
      script: './index.js',
      instances: 'max',
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      error_file: './logs/err.log',
      out_file: './logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      max_restarts: 10,
      min_uptime: '10s',
      watch: false,
      ignore_watch: ['node_modules', 'logs'],
      merge_logs: true,
      autorestart: true,
      max_memory_restart: '500M'
    }
  ]
};
