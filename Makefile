.PHONY: help setup fresh start stop restart clean db-setup db-reset db-seed db-migrate db-rollback test server console deps compile format check

# Default target
help:
	@echo "Superhero Dispatch - Available Commands:"
	@echo ""
	@echo "  make setup          - Initial project setup (deps + db + seeds)"
	@echo "  make fresh          - Fresh start (clean db + restart containers + seeds + run server)"
	@echo "  make start          - Start Docker containers"
	@echo "  make stop           - Stop Docker containers"
	@echo "  make restart        - Restart Docker containers"
	@echo "  make clean          - Stop containers and remove volumes"
	@echo ""
	@echo "  make db-setup     - Create, migrate, and seed database"
	@echo "  make db-reset     - Drop, create, migrate, and seed database"
	@echo "  make db-seed      - Run seeds only"
	@echo "  make db-migrate   - Run pending migrations"
	@echo "  make db-rollback  - Rollback last migration"
	@echo ""
	@echo "  make server       - Start Phoenix server"
	@echo "  make server.reset - Clean build and start Phoenix server (fixes Phoenix.Sync cache issues)"
	@echo "  make console      - Start IEx console with app"
	@echo ""
	@echo "  make deps         - Install dependencies"
	@echo "  make compile      - Compile the project"
	@echo "  make test         - Run tests"
	@echo "  make format       - Format code"
	@echo "  make check        - Run precommit checks"
	@echo ""

# Initial setup
setup: start deps db-setup
	@echo "✓ Setup complete! Run 'make server' to start the application."

# Fresh start with clean database and server
fresh: clean start
	@echo "Installing/updating dependencies..."
	mix deps.get
	@echo "Compiling project..."
	mix compile
	@echo "Waiting for database to be ready..."
	@sleep 3
	@echo "Setting up fresh database..."
	mix ecto.create
	mix ecto.migrate
	@echo "Running seeds..."
	mix run priv/repo/seeds.exs
	@echo "✓ Fresh database ready with seed data!"
	@echo "Starting Phoenix server..."
	iex -S mix phx.server

# Docker commands
start:
	@echo "Starting Docker containers..."
	docker compose up -d
	@echo "✓ Containers started"

stop:
	@echo "Stopping Docker containers..."
	docker compose stop
	@echo "✓ Containers stopped"

restart:
	@echo "Restarting Docker containers..."
	docker compose restart
	@echo "✓ Containers restarted"

clean:
	@echo "Stopping containers and removing volumes..."
	docker compose down -v
	@echo "✓ Cleanup complete"

# Database commands
db-setup:
	@echo "Creating and migrating database..."
	mix ecto.create
	mix ecto.migrate
	mix run priv/repo/seeds.exs
	@echo "✓ Database ready"

db-reset:
	@echo "Resetting database..."
	mix ecto.reset
	@echo "✓ Database reset complete"

db-seed:
	@echo "Running seeds..."
	mix run priv/repo/seeds.exs
	@echo "✓ Seeds complete"

db-migrate:
	@echo "Running migrations..."
	mix ecto.migrate
	@echo "✓ Migrations complete"

db-rollback:
	@echo "Rolling back last migration..."
	mix ecto.rollback
	@echo "✓ Rollback complete"

# Application commands
server:
	@echo "Starting Phoenix server..."
	iex -S mix phx.server

server.reset:
	@echo "Cleaning build artifacts to ensure fresh Phoenix.Sync state..."
	rm -rf _build
	@echo "Recompiling project..."
	mix compile --force
	@echo "Starting Phoenix server..."
	iex -S mix phx.server

console:
	@echo "Starting IEx console..."
	iex -S mix

# Development commands
deps:
	@echo "Installing dependencies..."
	mix deps.get
	@echo "✓ Dependencies installed"

compile:
	@echo "Compiling project..."
	mix compile
	@echo "✓ Compilation complete"

test:
	@echo "Running tests..."
	mix test

format:
	@echo "Formatting code..."
	mix format
	@echo "✓ Code formatted"

check:
	@echo "Running precommit checks..."
	mix precommit
	@echo "✓ All checks passed"
