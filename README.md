# YouTube Video Sharing Platform - Backend

## Introduction

This is a YouTube video sharing platform built with Ruby on Rails. The application allows users to register, login, share YouTube videos, and receive real-time notifications when new videos are shared. This repository contains the backend API and server-rendered views.

## Key Features

- User registration and authentication
- YouTube video sharing with [OpenGraph](https://ogp.me/) metadata extraction
- Real-time notifications via ActionCable (only broadcast on successful video creation)
- Background job processing with Sidekiq
- REST API endpoints for frontend integration
- Server-rendered views with Tailwind CSS
- IP blocking middleware for security

## Prerequisites

- Ruby 3.3.0
- Rails 7.2.3
- PostgreSQL 12+
- Redis 6+
- Docker or Podman (for containerized deployment)

## Installation & Configuration

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd remitano
   ```

2. Install dependencies
   ```bash
   bundle install
   ```

3. Configure environment variables
   
   Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` with your local configuration:
   ```bash
   # Database Configuration
   DB_HOST=localhost
   DB_PORT=5432
   DB_USERNAME=postgres
   DB_PASSWORD=password
   
   # Redis Configuration
   REDIS_SIDEKIQ_URL=redis://localhost:6379/0
   REDIS_CABLE_URL=redis://localhost:6379/1
   REDIS_IP_BLOCKER_URL=redis://localhost:6379/2
   
   # Rails Configuration
   SECRET_KEY_BASE=your_secret_key_base_here
   RAILS_MASTER_KEY=your_master_key_here
   
   # Action Cable Configuration
   ACTION_CABLE_MOUNT_PATH=/cable
   DISABLE_ACTION_CABLE_VERIFICATION=true
   
   # Server Configuration
   PORT=3000
   ```
   **Note:** Adjust these values to match your local setup. The Redis database numbers (0, 1, 2) can be any available Redis databases - they just need to be different from each other to avoid conflicts.

## Database Setup

1. Ensure PostgreSQL is running on your configured port (default: 5432)

2. Create and migrate the database
   ```bash
   rails db:setup
   # Or separately:
   rails db:create
   rails db:migrate
   ```

3. NOTE: For this simple application, database seed is not necessary

## Running the Application Locally

### Development Mode

1. Ensure Redis is running
   ```bash
   redis-cli ping
   # Should return: PONG
   ```

2. Start the Rails server and Sidekiq
   ```bash
   # Terminal 1: Rails server
   rails server
   
   # Terminal 2: Sidekiq background jobs
   bundle exec sidekiq
   
   # Or use foreman to run both:
   bin/dev
   ```

3. Access the application at `http://localhost:3000`

### Running Tests

```bash
bundle exec rspec
```

## Docker/Podman Deployment

### Building the Image

Build the Docker/Podman image:

```bash
# Using Docker
docker build -t vsharing:latest .

# Using Podman
podman build -t vsharing:latest .
```

### Running in Production Mode

```bash
# Using Docker
docker run -d \
  --name vsharing \
  -p 3990:3990 \
  -e DATABASE_URL="postgresql://user:pass@host.containers.internal:5432/dbname" \
  -e REDIS_SIDEKIQ_URL="redis://host.containers.internal:6379/0" \
  -e REDIS_CABLE_URL="redis://host.containers.internal:6379/1" \
  -e REDIS_IP_BLOCKER_URL="redis://host.containers.internal:6379/2" \
  -e RAILS_ENV="production" \
  -e SECRET_KEY_BASE="your_secret_key_base_here" \
  -e RAILS_MASTER_KEY="your_master_key_here" \
  -e PORT=3990 \
  -e FORCE_SSL="false" \
  vsharing:latest
```

**Note:** Replace `user:pass@host.containers.internal:5432/dbname` with your actual PostgreSQL credentials and database name.

Access the application at `http://localhost:3990`

### Running in Development Mode (Containerized)

```bash
# Using Docker
docker run -d \
  --name vsharing-dev \
  -p 3990:3990 \
  -e DATABASE_URL="postgresql://user:pass@host.containers.internal:5432/dbname" \
  -e REDIS_SIDEKIQ_URL="redis://host.containers.internal:6379/0" \
  -e REDIS_CABLE_URL="redis://host.containers.internal:6379/1" \
  -e REDIS_IP_BLOCKER_URL="redis://host.containers.internal:6379/2" \
  -e RAILS_ENV="development" \
  -e SECRET_KEY_BASE="your_secret_key_base_here" \
  -e RAILS_MASTER_KEY="your_master_key_here" \
  -e PORT=3990 \
  -e BINDING="0.0.0.0" \
  vsharing:latest
```

**Note:** 
- `host.containers.internal` allows the container to access services running on your host machine
- Replace `user:pass@host.containers.internal:5432/dbname` with your actual database credentials
- Adjust Redis database numbers (0, 1, 2) if they conflict with existing Redis data
- Set `FORCE_SSL="false"` for local testing without SSL
- Set `BINDING="0.0.0.0"` in development mode to make the server accessible from outside the container

## Dokku Deployment (Heroku-like PaaS)

Please follow the [Dokku documentation](https://dokku.com/docs/getting-started/installation/) for installation.

### Prerequisites

On your local machine:
```bash
gem install dokku-cli
```

### Deployment Steps

```bash
# On your Dokku host
dokku apps:create vsharing
dokku domains:add vsharing your-domain.com

# SSL with Let's Encrypt
dokku letsencrypt:set vsharing email your@email.com
dokku letsencrypt:enable vsharing

# Install plugins
dokku plugin:install https://github.com/dokku/dokku-postgres.git
dokku plugin:install https://github.com/dokku/dokku-redis.git redis

# Create and link PostgreSQL
dokku postgres:create vsharing-db
dokku postgres:link vsharing-db vsharing

# Create and link Redis
dokku redis:create vsharing-redis
dokku redis:link vsharing-redis vsharing

# Set environment variables
dokku config:set vsharing \
  RAILS_MASTER_KEY=your_master_key_here \
  SECRET_KEY_BASE=your_secret_key_base_here \
  REDIS_SIDEKIQ_URL=redis://redis:6379/0 \
  REDIS_CABLE_URL=redis://redis:6379/1 \
  REDIS_IP_BLOCKER_URL=redis://redis:6379/2 \
  ACTION_CABLE_MOUNT_PATH=/cable \
  DISABLE_ACTION_CABLE_VERIFICATION=true

# On your local machine
git remote add dokku dokku@your-domain:vsharing
git push dokku main
```

**Note:** Dokku automatically sets `DATABASE_URL` when you link the PostgreSQL service.

## Usage

### Authentication

The application uses Devise for cookie-based authentication for both server-rendered views and API endpoints.

### Sharing Videos

1. Login to your account
2. Navigate to the "Share a video" page
3. Enter a YouTube URL
4. Submit the form

The application uses OpenGraph to extract video metadata (title, description, thumbnail) from YouTube. Upon successful processing, a notification is broadcast to all connected users via ActionCable.

### API Endpoints

- `POST /api/v1/users/current` - Get current user id and email
- `POST /api/v1/users/sign_in_or_sign_up` - User login or registration
- `DELETE /api/v1/users/logout` - User logout
- `GET /api/v1/videos` - List videos
- `POST /api/v1/videos` - Share a video

## Architecture

### Redis Database Separation

The application uses separate Redis databases for different services to avoid data conflicts:
- **Database 0**: Sidekiq background jobs (default)
- **Database 1**: ActionCable WebSocket connections
- **Database 2**: IP blocking middleware

You can use any available Redis database numbers (0-15 by default), as long as they're different from each other and don't conflict with other applications using the same Redis instance.

### Action Cable

ActionCable runs in the same process as the Rails application (not separated). WebSocket connections are handled at the `/cable` endpoint.

### Asset Pipeline

The application uses:
- **Importmap** for JavaScript module management (no npm build required)
- **Tailwind CSS** for styling (compiled via `rails tailwindcss:build`)
- **Sprockets** for asset compilation

Assets are precompiled during Docker build for production deployment.

## Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Ensure PostgreSQL is running on the correct port (default: 5432)
   - Verify database credentials in `.env` file
   - Check `host: localhost` is set in `config/database.yml` for local development

2. **Redis Connection Error**
   - Ensure Redis server is running
   - Check REDIS_URL in configuration

3. **ActionCable Connection Issues**
   - Check that WebSocket routes are properly configured
   - Verify that Redis is running (used by ActionCable)

4. **Background Job Processing**
   - Ensure Sidekiq is running
   - Check Redis connection for Sidekiq

5. **Asset Compilation Issues**
   - Run `rails assets:precompile` to precompile assets
   - Run `rails tailwindcss:build` to compile Tailwind CSS

6. **Container Cannot Access Host Services**
   - Use `host.containers.internal` instead of `localhost` in container environment variables
   - Ensure PostgreSQL and Redis are listening on `0.0.0.0`, not just `127.0.0.1`

7. **403 Forbidden Errors**
   - The application includes IP blocking middleware
   - Check `app/middleware/ip_blocker.rb` for blocked IP addresses
   - Blocked IPs are stored in Redis (check your configured `REDIS_IP_BLOCKER_URL`)