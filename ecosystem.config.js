module.exports = {
  apps: [
    {
      name: 'bglmautam',
      script: 'bundle',
      args: 'exec puma -C config/puma.rb',
      cwd: '/Users/billle/projects/personal/bglmautam',
      interpreter: 'none',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        RAILS_ENV: 'production',
        RAILS_SERVE_STATIC_FILES: 'true',
        RAILS_LOG_TO_STDOUT: 'true',
        NODE_ENV: 'production'
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
