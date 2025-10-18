defmodule SuperheroDispatchWeb.IncidentLive.Show do
  use SuperheroDispatchWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Incident {@incident.id}
        <:subtitle>This is a incident record from your database.</:subtitle>

        <:actions>
          <.button navigate={~p"/incidents"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/incidents/#{@incident}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit Incident
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Id">{@incident.id}</:item>

        <:item title="Incident number">{@incident.incident_number}</:item>

        <:item title="Incident type">{@incident.incident_type}</:item>

        <:item title="Description">{@incident.description}</:item>

        <:item title="Location">{@incident.location}</:item>

        <:item title="Priority">{@incident.priority}</:item>

        <:item title="Status">{@incident.status}</:item>

        <:item title="Reported at">{@incident.reported_at}</:item>

        <:item title="Dispatched at">{@incident.dispatched_at}</:item>

        <:item title="Resolved at">{@incident.resolved_at}</:item>

        <:item title="Closed at">{@incident.closed_at}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Incident")
     |> assign(:incident, Ash.get!(SuperheroDispatch.Dispatch.Incident, id))}
  end
end
