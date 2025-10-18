defmodule SuperheroDispatch.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SuperheroDispatchWeb.Telemetry,
      SuperheroDispatch.Repo,
      {DNSCluster,
       query: Application.get_env(:superhero_dispatch, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SuperheroDispatch.PubSub},
      {SuperheroDispatchWeb.Endpoint, phoenix_sync: Phoenix.Sync.plug_opts()}
    ]

    opts = [strategy: :one_for_one, name: SuperheroDispatch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    SuperheroDispatchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
