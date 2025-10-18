defmodule SuperheroDispatchWeb.IncidentLive.Index do
  use SuperheroDispatchWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Incidents
        <:actions>
          <.button variant="primary" navigate={~p"/incidents/new"}>
            <.icon name="hero-plus" /> New Incident
          </.button>
        </:actions>
      </.header>

      <.table
        id="incidents"
        rows={@streams.incidents}
        row_click={fn {_id, incident} -> JS.navigate(~p"/incidents/#{incident}") end}
      >
        <:col :let={{_id, incident}} label="Id">{incident.id}</:col>

        <:col :let={{_id, incident}} label="Incident number">{incident.incident_number}</:col>

        <:col :let={{_id, incident}} label="Incident type">{incident.incident_type}</:col>

        <:col :let={{_id, incident}} label="Description">{incident.description}</:col>

        <:col :let={{_id, incident}} label="Location">{incident.location}</:col>

        <:col :let={{_id, incident}} label="Priority">{incident.priority}</:col>

        <:col :let={{_id, incident}} label="Status">{incident.status}</:col>

        <:col :let={{_id, incident}} label="Reported at">{incident.reported_at}</:col>

        <:col :let={{_id, incident}} label="Dispatched at">{incident.dispatched_at}</:col>

        <:col :let={{_id, incident}} label="Resolved at">{incident.resolved_at}</:col>

        <:col :let={{_id, incident}} label="Closed at">{incident.closed_at}</:col>

        <:action :let={{_id, incident}}>
          <div class="sr-only">
            <.link navigate={~p"/incidents/#{incident}"}>Show</.link>
          </div>

          <.link navigate={~p"/incidents/#{incident}/edit"}>Edit</.link>
        </:action>

        <:action :let={{id, incident}}>
          <.link
            phx-click={JS.push("delete", value: %{id: incident.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Incidents")
     |> stream(:incidents, Ash.read!(SuperheroDispatch.Dispatch.Incident))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    incident = Ash.get!(SuperheroDispatch.Dispatch.Incident, id)
    Ash.destroy!(incident)

    {:noreply, stream_delete(socket, :incidents, incident)}
  end
end
