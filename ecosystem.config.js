module.exports = {
  apps: [
    {
      name: 'bglmautam',
      script: 'bundle',
      args: 'exec rails s -e production -b 127.0.0.1 -p 3000',
      cwd: '/root/bglmautam',
      interpreter: 'none',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        RAILS_ENV: 'production',
        RAILS_SERVE_STATIC_FILES: 'true',
        RAILS_LOG_TO_STDOUT: 'true',
        NODE_ENV: 'production',
        CORS_ORIGINS: 'https://acadex.bglmautam.com'
      },
      error_file: './log/pm2-error.log',
      out_file: './log/pm2-out.log',
      log_file: './log/pm2-combined.log',
      time: true,
      merge_logs: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z'
    }
  ]
};
