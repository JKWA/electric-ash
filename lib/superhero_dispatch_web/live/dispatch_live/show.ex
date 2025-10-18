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
      where: a.incident_id == ^incident_id and is_nil(a.archived_at)
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

  defp assignment_status_class(:assigned), do: "badge-info"
  defp assignment_status_class(:en_route), do: "badge-primary"
  defp assignment_status_class(:on_scene), do: "badge-warning"
  defp assignment_status_class(:completed), do: "badge-success"
end
