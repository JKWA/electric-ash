defmodule SuperheroDispatchWeb.IncidentLive.Form do
  use SuperheroDispatchWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage incident records in your database.</:subtitle>
      </.header>

      <.form
        for={@form}
        id="incident-form"
        phx-change="validate"
        phx-submit="save"
      >
        <%= if @form.source.type == :create do %>
          <.input field={@form[:incident_number]} type="text" label="Incident number" /><.input
            field={@form[:incident_type]}
            type="text"
            label="Incident type"
          /><.input field={@form[:description]} type="text" label="Description" /><.input
            field={@form[:location]}
            type="text"
            label="Location"
          /><.input
            field={@form[:priority]}
            type="select"
            label="Priority"
            options={
              Ash.Resource.Info.attribute(SuperheroDispatch.Dispatch.Incident, :priority).constraints[
                :one_of
              ]
            }
          />
        <% end %>
        <%= if @form.source.type == :update do %>
          <.input field={@form[:incident_type]} type="text" label="Incident type" /><.input
            field={@form[:description]}
            type="text"
            label="Description"
          /><.input field={@form[:location]} type="text" label="Location" /><.input
            field={@form[:priority]}
            type="select"
            label="Priority"
            options={
              Ash.Resource.Info.attribute(SuperheroDispatch.Dispatch.Incident, :priority).constraints[
                :one_of
              ]
            }
          />
        <% end %>

        <.button phx-disable-with="Saving..." variant="primary">Save Incident</.button>
        <.button navigate={return_path(@return_to, @incident)}>Cancel</.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    incident =
      case params["id"] do
        nil -> nil
        id -> Ash.get!(SuperheroDispatch.Dispatch.Incident, id)
      end

    action = if is_nil(incident), do: "New", else: "Edit"
    page_title = action <> " " <> "Incident"

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(incident: incident)
     |> assign(:page_title, page_title)
     |> assign_form()}
  end

  defp return_to("show"), do: "show"
  defp return_to("dispatch"), do: "dispatch"
  defp return_to(_), do: "index"

  @impl true
  def handle_event("validate", %{"incident" => incident_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, incident_params))}
  end

  def handle_event("save", %{"incident" => incident_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: incident_params) do
      {:ok, incident} ->
        notify_parent({:saved, incident})

        socket =
          socket
          |> put_flash(:info, "Incident #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: return_path(socket.assigns.return_to, incident))

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{incident: incident}} = socket) do
    form =
      if incident do
        AshPhoenix.Form.for_update(incident, :update, as: "incident")
      else
        AshPhoenix.Form.for_create(SuperheroDispatch.Dispatch.Incident, :create, as: "incident")
      end

    assign(socket, form: to_form(form))
  end

  defp return_path("index", _incident), do: ~p"/incidents"
  defp return_path("show", incident), do: ~p"/incidents/#{incident.id}"
  defp return_path("dispatch", incident), do: ~p"/dispatch/#{incident.id}"
end
