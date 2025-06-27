defmodule StoicBard.Repo do
  use Ecto.Repo,
    otp_app: :stoic_bard,
    adapter: Ecto.Adapters.Postgres
end
