defmodule SuperheroDispatchWeb.SuperheroLive.Form do
  use SuperheroDispatchWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage superhero records in your database.</:subtitle>
      </.header>

      <.form
        for={@form}
        id="superhero-form"
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:hero_alias]} type="text" label="Hero alias" />
        <.input
          field={@form[:powers]}
          type="select"
          multiple
          label="Powers"
          options={[{"Option 1", "option1"}, {"Option 2", "option2"}]}
        />
        <.input field={@form[:current_location]} type="text" label="Current location" />

        <.button phx-disable-with="Saving..." variant="primary">Save Superhero</.button>
        <.button navigate={return_path(@return_to, @superhero)}>Cancel</.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    superhero =
      case params["id"] do
        nil -> nil
        id -> Ash.get!(SuperheroDispatch.Dispatch.Superhero, id)
      end

    action = if is_nil(superhero), do: "New", else: "Edit"
    page_title = action <> " " <> "Superhero"

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(superhero: superhero)
     |> assign(:page_title, page_title)
     |> assign_form()}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  @impl true
  def handle_event("validate", %{"superhero" => superhero_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, superhero_params))}
  end

  def handle_event("save", %{"superhero" => superhero_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: superhero_params) do
      {:ok, superhero} ->
        notify_parent({:saved, superhero})

        socket =
          socket
          |> put_flash(:info, "Superhero #{socket.assigns.form.source.type}d successfully")
          |> push_navigate(to: return_path(socket.assigns.return_to, superhero))

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{superhero: superhero}} = socket) do
    form =
      if superhero do
        AshPhoenix.Form.for_update(superhero, :update, as: "superhero")
      else
        AshPhoenix.Form.for_create(SuperheroDispatch.Dispatch.Superhero, :create, as: "superhero")
      end

    assign(socket, form: to_form(form))
  end

  defp return_path("index", _superhero), do: ~p"/superheroes"
  defp return_path("show", superhero), do: ~p"/superheroes/#{superhero.id}"
end
