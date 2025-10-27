# Superhero Dispatch

An exploration of building real-time applications with Ash Framework and Electric SQL.

## About

This project explores two complementary technologies:

- Ash Framework - A declarative extension of Ecto that defines resources with schemas and actions, reducing boilerplate while enforcing consistent patterns through an opinionated design.
- Electric SQL with Phoenix Sync - A real-time sync engine that watches the Postgres WAL and streams changes directly to clients, eliminating manual PubSub logic, subscriptions, and message ordering concerns.

## Getting Started

### Prerequisites

- Elixir
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

### Project Technologies

- Ash Framework: https://ash-hq.org
- Electric SQL: https://electric-sql.com/docs
- Phoenix Sync: https://hexdocs.pm/phoenix_sync/readme.html
- Phoenix: https://www.phoenixframework.org/
- Ecto: https://hexdocs.pm/ecto/Ecto.html
- Elixir: https://elixir-lang.org/
