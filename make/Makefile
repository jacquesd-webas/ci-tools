.PHONY: up down clean migrate help env

DOCKER_COMPOSE := docker compose -f docker-compose.yml

help:
	@echo "up          Start services"
	@echo "down        Stop services"
	@echo "db-up       Start Postgres only"
	@echo "db-migrate  Run DB migrations (pnpm, assumes db is up)"
	@echo "clean       Stop and remove volumes (blows away data)"

up:
	$(DOCKER_COMPOSE) up -d db

migrate:
	$(DOCKER_COMPOSE) run --build --rm db_migrate

down:
	$(DOCKER_COMPOSE) down

clean:
	$(DOCKER_COMPOSE) down -v

env:
	./env/make-env.sh $(ENVIRONMENT)
