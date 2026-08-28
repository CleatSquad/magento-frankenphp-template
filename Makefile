# Magento Docker FrankenPHP - Makefile
# Common commands for managing the Docker environment

# Load environment file if it exists
ifneq ("$(wildcard .env)","")
	include env/*.env
	include .env
	export
endif

# Configuration
APP := app
PROFILE := dev

# Default shell
SHELL := /bin/bash

.PHONY: help init setup-magento uninstall-magento \
        up down restart build logs status clean clean-all \
        shell permissions \
        cache reindex compile upgrade deploy \
        composer-install composer-update composer-require \
        mysql mysqldump \
        test-unit test-integration test-api \
        prod-up prod-down prod-restart prod-build prod-logs prod-status prod-clean prod-clean-all \
        version

# Default target - display help
.DEFAULT_GOAL := help

# Initialize and start the project (setup + start containers)
init:
	./bin/setup
	./bin/start

# Install Magento with interactive setup
setup-magento:
	./bin/setup-magento

# Uninstall Magento (removes all data)
uninstall-magento:
	./bin/uninstall-magento

# Start Docker containers
up:
	./bin/start

# Stop Docker containers
down:
	docker compose --profile $(PROFILE) stop

# Restart Docker containers
restart:
	docker compose --profile $(PROFILE) restart

# Build Docker images
build:
	docker compose build

# Follow container logs
logs:
	docker compose --profile $(PROFILE) logs -f

# Show container status
status:
	docker compose --profile $(PROFILE) ps

# Remove containers
clean:
	docker compose --profile $(PROFILE) down

# Remove containers, volumes and networks
clean-all:
	docker compose --profile $(PROFILE) down -v

# Open a shell in the app container
shell:
	./bin/shell

# Fix file permissions and ownership
permissions:
	./bin/fix-permissions

# Clear all Magento caches
cache:
	./bin/magento cache:flush

# Reindex all Magento indexers
reindex:
	./bin/magento indexer:reindex

# Compile dependency injection
compile:
	./bin/magento setup:di:compile

# Run Magento setup upgrade
upgrade:
	./bin/magento setup:upgrade

# Deploy static content
deploy:
	./bin/magento setup:static-content:deploy -f

# Install Composer dependencies
composer-install:
	./bin/composer install

# Update Composer dependencies
composer-update:
	./bin/composer update

# Require a new Composer package (usage: make composer-require PKG=vendor/package)
composer-require:
	./bin/composer require $(PKG)

# --- Production (docker-compose.prod.yml) ---

# Start production containers
prod-up:
	docker compose -f docker-compose.prod.yml --profile prod up -d

# Stop production containers
prod-down:
	docker compose -f docker-compose.prod.yml --profile prod stop

# Restart production containers
prod-restart:
	docker compose -f docker-compose.prod.yml --profile prod restart

# Build production image (Dockerfile.prod, if enabled in docker-compose.prod.yml)
prod-build:
	docker compose -f docker-compose.prod.yml build

# Follow production container logs
prod-logs:
	docker compose -f docker-compose.prod.yml --profile prod logs -f

# Show production container status
prod-status:
	docker compose -f docker-compose.prod.yml --profile prod ps

# Remove production containers
prod-clean:
	docker compose -f docker-compose.prod.yml --profile prod down

# Remove production containers, volumes and networks
prod-clean-all:
	docker compose -f docker-compose.prod.yml --profile prod down -v

# Access MySQL CLI
mysql:
	./bin/mysql

# Dump database
mysqldump:
	./bin/mysqldump

# Run Magento unit tests
test-unit:
	./bin/magento dev:tests:run unit

# Run Magento integration tests
test-integration:
	./bin/magento dev:tests:run integration

# Run Magento API tests
test-api:
	./bin/magento dev:tests:run api

# Display PHP version
version:
	docker compose exec $(APP) php -v

# Display help
help:
	@echo "Magento Docker FrankenPHP - Available Commands"
	@echo ""
	@echo "🚀 Quick Start:"
	@echo "  make init              - Initialize and start project (first time)"
	@echo "  make up                - Start containers"
	@echo "  make down              - Stop containers"
	@echo ""
	@echo "📦 Container Management:"
	@echo "  make build             - Build Docker images"
	@echo "  make restart           - Restart containers"
	@echo "  make status            - Show container status"
	@echo "  make logs              - Follow container logs"
	@echo "  make clean             - Remove containers"
	@echo "  make clean-all         - Remove containers + volumes"
	@echo "  make shell             - Open shell in app container"
	@echo ""
	@echo "🎯 Magento Commands:"
	@echo "  make setup-magento     - Interactive Magento installation"
	@echo "  make uninstall-magento - Uninstall Magento"
	@echo "  make cache             - Clear all caches"
	@echo "  make reindex           - Reindex all indexers"
	@echo "  make compile           - Compile dependency injection"
	@echo "  make upgrade           - Run setup:upgrade"
	@echo "  make deploy            - Deploy static content"
	@echo "  make permissions       - Fix file permissions"
	@echo ""
	@echo "📚 Composer:"
	@echo "  make composer-install  - Install dependencies"
	@echo "  make composer-update   - Update dependencies"
	@echo "  make composer-require  - Add package (PKG=vendor/package)"
	@echo ""
	@echo "🗄️  Database:"
	@echo "  make mysql             - Access MySQL CLI"
	@echo "  make mysqldump         - Dump database"
	@echo ""
	@echo "🏭 Production (docker-compose.prod.yml):"
	@echo "  make prod-up           - Start production containers"
	@echo "  make prod-down         - Stop production containers"
	@echo "  make prod-restart      - Restart production containers"
	@echo "  make prod-build        - Build production image"
	@echo "  make prod-logs         - Follow production logs"
	@echo "  make prod-status       - Show production container status"
	@echo "  make prod-clean        - Remove production containers"
	@echo "  make prod-clean-all    - Remove production containers + volumes"
	@echo ""
	@echo "🧪 Testing:"
	@echo "  make test-unit         - Run unit tests"
	@echo "  make test-integration  - Run integration tests"
	@echo "  make test-api          - Run API tests"
	@echo ""
	@echo "ℹ️  Other:"
	@echo "  make version           - Display PHP version"
	@echo ""
	@echo "For detailed documentation, see: docs/CLI.md"
