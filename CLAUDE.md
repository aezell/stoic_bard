# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

**Setup and Installation:**
- `mix setup` - Install dependencies, setup database, and build assets
- `mix deps.get` - Install Elixir dependencies only

**Development Server:**
- `mix phx.server` - Start Phoenix server (visit localhost:4000)
- `iex -S mix phx.server` - Start server in interactive Elixir shell

**Database Management:**
- `mix ecto.create` - Create database
- `mix ecto.migrate` - Run migrations
- NEVER run mix ecto.drop or mix ecto.setup. This app is connected to a production DB and that will destroy data.

**Testing:**
- `mix test` - Run all tests (automatically creates test DB and runs migrations)

**Asset Management:**
- `mix assets.build` - Build assets for development
- `mix assets.deploy` - Build and minify assets for production
- Always run `mix compile` after your changes.
- Always run `mix format` after your changes.

## Architecture Overview

**Core Application Structure:**
- Phoenix web framework with LiveView for interactive components
- Ecto for database ORM with PostgreSQL
- Authentication system with user sessions and scopes
- Asset pipeline using Tailwind CSS and esbuild


**Web Layer:**
- LiveView components for every view
- Authentication pipelines with scope-based access control

**Database:**
- PostgreSQL for development
- Ecto migrations in `priv/repo/migrations/`
- Seeds in `priv/repo/seeds.exs`

**Frontend:**
- Tailwind CSS for styling
- JavaScript enhancements in `assets/js/`
- LiveView for reactive components
- HEEx templates for server-rendered HTML

**Architecture:**
- Phoenix 1.7+ app with LiveView, Ecto (PostgreSQL), Tailwind CSS, DaisyUI
- Main contexts: `Accounts` (user auth), `Catalog` (products)
- Web layer: `StoicBardWeb` with LiveView components, controllers
- Database: PostgreSQL via Ecto, migrations in `priv/repo/migrations/` powered by Supabase

**Code Style:**
- Follow Elixir/Phoenix conventions and .formatter.exs config
- Import deps: `:phoenix` in formatter
- Use LiveView HTML formatter for .heex templates
- Module names: `StoicBard.*` for contexts, `StoicBardWeb.*` for web
- Always check mix.exs for correct dependency versions before suggesting changes
- Minimize JavaScript usage except when completely necessary. If you have to use Javascript, prefer vanilla JS over importing libraries.

**Don'ts:**
- NEVER RUN mix ecto.reset
- NEVER do anything that will save data to the database
- NEVER do anything that will truncate, erase, or drop data in the database

**Erlang and Elixir Best Practices:**
- Only drop to `erlang` functions when absolutely necessary. Ask for approval before doing so while explaining why it's necessary.