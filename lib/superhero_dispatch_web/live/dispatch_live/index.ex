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
     |> sync_stream(:superheroes, from(s in Superhero), id_key: :id)}
  end

  @impl true
  def handle_info({:sync, event}, socket) do
    {:noreply, sync_stream_update(socket, event)}
  end

  # Helper functions for styling
  defp priority_class(:critical), do: "bg-red-100 text-red-800"
  defp priority_class(:high), do: "bg-orange-100 text-orange-800"
  defp priority_class(:medium), do: "bg-yellow-100 text-yellow-800"
  defp priority_class(:low), do: "bg-green-100 text-green-800"

  defp status_class(:reported), do: "bg-blue-100 text-blue-800"
  defp status_class(:dispatched), do: "bg-purple-100 text-purple-800"
  defp status_class(:in_progress), do: "bg-amber-100 text-amber-800"
  defp status_class(:resolved), do: "bg-green-100 text-green-800"
  defp status_class(:closed), do: "bg-gray-100 text-gray-800"

  defp hero_status_class(:available), do: "bg-green-100 text-green-800"
  defp hero_status_class(:dispatched), do: "bg-blue-100 text-blue-800"
  defp hero_status_class(:on_scene), do: "bg-orange-100 text-orange-800"
  defp hero_status_class(:off_duty), do: "bg-gray-100 text-gray-800"
end
