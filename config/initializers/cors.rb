# CORS configuration for React frontend
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow specific origins - defaults to localhost:3001 for React dev server
    origins ENV.fetch('CORS_ORIGINS', 'http://localhost:3001').split(',')

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true,
      max_age: 600
  end
end