# YouTube Video Sharing Platform - Backend

## Introduction

This is a YouTube video sharing platform built with Ruby on Rails. The application allows users to register, login, share YouTube videos, and receive real-time notifications when new videos are shared. This repository contains the backend API and server-rendered views.

## Key Features

- User registration and authentication
- YouTube video sharing with [OpenGraph](https://ogp.me/) metadata extraction
- Real-time notifications via ActionCable (only broadcast on successful video creation)
- Background job processing with Sidekiq
- REST API endpoints for frontend integration
- Server-rendered views.
  - Views with embedded React components ( TO DO )

## Prerequisites

- Ruby 3.3.0
- Rails 7.1.5
- PostgreSQL 12+
- Redis 6+
- Node.js 18+ and Yarn (for asset compilation)

## Installation & Configuration

1. Clone the repository
   ```bash
   $ git clone <repository-url>
   $ cd remitano
   ```

2. Install dependencies
   ```bash
   $ bundle install
   ```

3. Configure environment variables
   Create a `.env` file in the root directory with the following variables:
   ```
   DATABASE_URL=postgres://username:password@localhost/remitano_development
   REDIS_URL=redis://localhost:6379/0
   SECRET_KEY_BASE=your_secret_key_base
   ```

## Database Setup

1. Create and migrate the database
   ```bash
   $ rails db:prepare
   # Or
   $ rails db:create
   $ rails db:migrate
   ```

2. NOTE: For this simple application, database seed is not necessary

## Running the Application

1. Assuring the redis is running
   ```bash
   $ redis-cli ping
   PONG
   ```

2. Start the application
   ```bash
   $ rails server
   $ bundle exec sidekiq
   ```

3. Access the application at `http://localhost:3000`

5. Run the test suite
   ```bash
   $ bundle exec rspec
   ```

## Docker Deployment

1. Build the Docker image
   ```bash
   $ docker build -t youtube-video-sharing .
   ```

2. Run the application with docker
   ```bash
   $ docker run -p 3000:3000 \                                                                                                                   ─╯
    -e SECRET_KEY_BASE=$(rails secret) \
    -e DATABASE_URL="postgres://pixie:root@host.docker.internal:5432/remitano_production" \
    -e REDIS_CABLE_URL="redis://host.docker.internal:6379/1" \
    -e REDIS_SIDEKIQ_URL="redis://host.docker.internal:6379/0" \
    -e PORT=3000 \
    -e ACTION_CABLE_ALLOWED_ORIGINS="http://localhost:3001" \
    --name video-sharing-be youtube-video-sharing:local
   ```
## Dokku Deployment( A Heroku-like on your own server)
Please following this [documentation](https://dokku.com/docs/getting-started/installation/) for how to deploy with dokku :rocket:
### The steps below is the deployment with my homelab
### Prerequisites
- On your local machine
```bash
$ gem install dokku-cli
```

### Steps
```bash
# On your host
$ dokku apps:create "app-name"
$ dokku domains:add "app-name" "domain-name.com"
$ dokku letsencrypt:set "app-name" email "your@email.com"
$ dokku letsencrypt:enable "app-name"
$ dokku plugin:install https://github.com/dokku/dokku-postgres.git
$ dokku plugin:install https://github.com/dokku/dokku-redis.git redis

# Create and link DB
$ dokku postgres:create "app-name-db"
$ dokku postgres:link "app-name-db" "app-name"

# Create and link DB

$ dokku redis:create "app-name-db"
$ dokku redis:link "app-name-db" "app-name"

# On local machine
$ git remote add dokku dokku@your-domain:app-name
$ dokku config:set RAILS_MASTER_KEY=master-key-go-here ... and other environment variables could be found in ,env.example
$ git push dokku main

DONE
```


## Usage

### Authentication

The application uses cookie-based authentication for both server-rendered views and API endpoints.

### Sharing Videos

1. Login to your account
2. Navigate to the "Share a video" page
3. Enter a YouTube URL
4. Submit the form

The application uses OpenGraph to extract video metadata (title, description, thumbnail) from YouTube. Upon successful processing, a notification is broadcast to all connected users via ActionCable.

### API Endpoints

- `POST /api/v1/users/current` - Get current user id and email
- `POST /api/v1/users/sign_in_or_sign_up` - User login or registration
- `DELETE /api/v1/users/logout` - User login or registration
- `GET /api/v1/videos` - List videos
- `POST /api/v1/videos` - Share a video

## Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Ensure PostgreSQL is running
   - Verify database credentials in `.env` file

2. **Redis Connection Error**
   - Ensure Redis server is running
   - Check REDIS_URL in configuration

3. **ActionCable Connection Issues**
   - Check that WebSocket routes are properly configured
   - Verify that Redis is running (used by ActionCable)

4. **Background Job Processing**
   - Ensure Sidekiq is running
   - Check Redis connection for Sidekiq
