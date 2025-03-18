# Docker Setup and Usage

This document describes how to use Docker with the Ruby Agent MVP application.

## Prerequisites

- Docker
- Docker Compose

## Development Environment

The development environment is configured in `docker-compose.yml` and includes:

- Rails application
- PostgreSQL database
- Redis
- Sidekiq worker

### Starting the Development Environment

```bash
# Start all services
bin/docker-dev

# Start in detached mode
bin/docker-dev -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Running Commands in Containers

```bash
# Run Rails commands
docker-compose exec web bundle exec rails console
docker-compose exec web bundle exec rails db:migrate

# Run tests
docker-compose exec web bundle exec rspec

# Access PostgreSQL
docker-compose exec postgres psql -U postgres
```

## Production Environment

The production environment is configured in `docker-compose.prod.yml` and is optimized for deployment.

### Required Environment Variables

- `DATABASE_HOST`
- `DATABASE_USERNAME`
- `DATABASE_PASSWORD`
- `REDIS_URL`
- `SECRET_KEY_BASE`
- `RAILS_MASTER_KEY`

### Starting the Production Environment

```bash
# Start all services
bin/docker-prod

# Start in detached mode
bin/docker-prod -d
```

## Volumes

The following Docker volumes are used:

- `postgres_data`: Persists PostgreSQL data
- `redis_data`: Persists Redis data
- `bundle_cache`: Caches Ruby gems

## Customization

### Custom Database Configuration

Update the database configuration in `config/database.yml` and environment variables in `docker-compose.yml` or `docker-compose.prod.yml`.

### Custom Redis Configuration

Update the Redis configuration in `config/redis.yml` and environment variables in the Docker Compose files.

## Troubleshooting

### Common Issues

1. **Database Connection Issues**
   - Check if PostgreSQL container is running
   - Verify database credentials in environment variables
   - Ensure database host is set correctly

2. **Redis Connection Issues**
   - Check if Redis container is running
   - Verify Redis URL in environment variables

3. **Asset Compilation Issues**
   - Run `docker-compose exec web bundle exec rails assets:precompile`
   - Check Node.js and Yarn installation in the container

### Useful Commands

```bash
# Remove all containers and volumes
docker-compose down -v

# Rebuild containers
docker-compose build --no-cache

# View container logs
docker-compose logs -f [service_name]

# Shell access to containers
docker-compose exec [service_name] bash
``` 