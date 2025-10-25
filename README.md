# Superhero Dispatch

An exploration of building real-time applications with Ash Framework and Electric SQL. This project demonstrates how Ash's declarative resources eliminate Ecto boilerplate while Electric's database sync provides effortless real-time updates by streaming changes directly from the Postgres write-ahead log.

## About

This project explores two complementary technologies:

- Ash Framework - A declarative extension of Ecto that defines resources with schemas and actions, reducing boilerplate while enforcing consistent patterns through an opinionated design.
- Electric SQL with Phoenix Sync - A real-time sync engine that watches the Postgres WAL and streams changes directly to clients, eliminating manual PubSub logic, subscriptions, and message ordering concerns.

The demo application manages superhero dispatches to incidents, showcasing how these technologies work together for building real-time collaborative applications.

## Getting Started

### Prerequisites

- Elixir 1.14+
- Docker & Docker Compose

### Quick Start

```bash
# Setup and start
make setup
make server

# Or using mix
mix setup && mix docker.start
iex -S mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000) from your browser.

### Other Commands

Run `make help` to see all available commands for database management, Docker control, and development tasks.

## Documentation

### Project Technologies

- Ash Framework: https://hexdocs.pm/ash/get-started.html
- Ash Resources: https://hexdocs.pm/ash/resources.html
- Electric SQL: https://electric-sql.com/docs
- Phoenix Sync: https://electric-sql.com/docs/guides/phoenix

### Phoenix & Elixir

- Phoenix Framework: https://www.phoenixframework.org/
- Phoenix Guides: https://hexdocs.pm/phoenix/overview.html
- Phoenix Docs: https://hexdocs.pm/phoenix
- Elixir: https://elixir-lang.org/
- Ecto: https://hexdocs.pm/ecto/Ecto.html
