defmodule SuperheroDispatchWeb.DispatchLive.Index do
  use SuperheroDispatchWeb, :live_view
  import Phoenix.Sync.LiveView

  alias SuperheroDispatch.Dispatch.{Incident, Superhero}
  import Ecto.Query

  @impl true
  def mount(_params, _session, socket) do
    # Using Phoenix.Sync for real-time reads
    {:ok,
     socket
     |> assign(:page_title, "Superhero Dispatch")
     |> sync_stream(:incidents, Incident, id_key: :id)
     |> sync_stream(:superheroes, Superhero, id_key: :id)}
  end

  @impl true
  def handle_info({:sync, event}, socket) do
    {:noreply, sync_stream_update(socket, event)}
  end

  # Helper functions for styling using DaisyUI badge variants
  defp priority_class(:critical), do: "badge-error"
  defp priority_class(:high), do: "badge-warning"
  defp priority_class(:medium), do: "badge-info"
  defp priority_class(:low), do: "badge-success"

  defp priority_border_class(:critical), do: "border-error"
  defp priority_border_class(:high), do: "border-warning"
  defp priority_border_class(:medium), do: "border-info"
  defp priority_border_class(:low), do: "border-success"

  defp status_class(:reported), do: "badge-info"
  defp status_class(:dispatched), do: "badge-primary"
  defp status_class(:in_progress), do: "badge-warning"
  defp status_class(:resolved), do: "badge-success"
  defp status_class(:closed), do: "badge-ghost"

  defp hero_status_class(:available), do: "badge-success"
  defp hero_status_class(:dispatched), do: "badge-primary"
  defp hero_status_class(:unavailable), do: "badge-ghost"
end
