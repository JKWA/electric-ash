defmodule SuperheroDispatchWeb.DispatchLive.Show do
  use SuperheroDispatchWeb, :live_view
  import Phoenix.Sync.LiveView
  import Phoenix.Component
  import Phoenix.LiveView

  alias SuperheroDispatch.Dispatch
  alias SuperheroDispatch.Dispatch.{Incident, Superhero, Assignment}
  import Ecto.Query
  require Ecto.Query
  require Logger

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Incident Details")
      |> assign(:incident_id, id)
      |> sync_stream(:incident, from(i in Incident, where: i.id == ^id), id_key: :id)
      |> sync_stream(:assignments, assignments_query(id),
        id_key: :id,
        reset?: true
      )
      |> sync_stream(:superheroes, available_superheroes_query(), id_key: :id)

    {:ok, socket}
  end

  defp assignments_query(incident_id) do
    from a in Assignment,
      where: a.incident_id == ^incident_id
  end

  defp available_superheroes_query do
    from s in Superhero,
      where: s.status == :available
  end

  @impl true
  def handle_event("assign_hero", %{"hero_id" => hero_id}, socket) do
    case Dispatch.create_assignment(%{
           superhero_id: hero_id,
           incident_id: socket.assigns.incident_id
         }) do
      {:ok, _assignment} ->
        {:noreply, put_flash(socket, :info, "Superhero assigned successfully")}

      _ ->
        {:noreply, put_flash(socket, :error, "Failed to assign superhero")}
    end
  end

  @impl true
  def handle_event("remove_assignment", %{"assignment_id" => id}, socket) do
    try do
      assignment = Dispatch.get_assignment!(id)

      case Dispatch.delete_assignment(assignment) do
        {:ok, _deleted} ->
          {:noreply, put_flash(socket, :info, "Assignment removed")}

        :ok ->
          {:noreply, put_flash(socket, :info, "Assignment removed")}

        {:error, error} ->
          Logger.error("Failed to delete assignment #{id}: #{inspect(error)}")
          {:noreply, put_flash(socket, :error, "Failed to remove assignment")}
      end
    rescue
      Ash.Error.Invalid ->
        {:noreply, put_flash(socket, :info, "Assignment already removed")}
    end
  end

  @impl true
  def handle_info({:sync, event}, socket) do
    Logger.debug("Sync event: #{inspect(event, pretty: true)}")

    {:noreply, sync_stream_update(socket, event)}
  end

  defp priority_class(:critical), do: "bg-red-100 text-red-800"
  defp priority_class(:high), do: "bg-orange-100 text-orange-800"
  defp priority_class(:medium), do: "bg-yellow-100 text-yellow-800"
  defp priority_class(:low), do: "bg-green-100 text-green-800"

  defp status_class(:reported), do: "bg-blue-100 text-blue-800"
  defp status_class(:dispatched), do: "bg-purple-100 text-purple-800"
  defp status_class(:in_progress), do: "bg-amber-100 text-amber-800"
  defp status_class(:resolved), do: "bg-green-100 text-green-800"
  defp status_class(:closed), do: "bg-gray-100 text-gray-800"

  defp assignment_status_class(:assigned), do: "bg-blue-100 text-blue-800"
  defp assignment_status_class(:en_route), do: "bg-purple-100 text-purple-800"
  defp assignment_status_class(:on_scene), do: "bg-orange-100 text-orange-800"
  defp assignment_status_class(:completed), do: "bg-green-100 text-green-800"
end
