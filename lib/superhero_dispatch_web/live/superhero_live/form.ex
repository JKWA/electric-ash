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
          type="textarea"
          label="Powers (one per line)"
          phx-debounce="300"
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
    superhero_params = parse_powers(superhero_params)
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, superhero_params))}
  end

  def handle_event("save", %{"superhero" => superhero_params}, socket) do
    superhero_params = parse_powers(superhero_params)
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
    # Prepare params with powers as newline-separated string for textarea
    params = if superhero && superhero.powers && is_list(superhero.powers) do
      %{"powers" => Enum.join(superhero.powers, "\n")}
    else
      %{}
    end

    form =
      if superhero do
        AshPhoenix.Form.for_update(superhero, :update, as: "superhero", params: params)
      else
        AshPhoenix.Form.for_create(SuperheroDispatch.Dispatch.Superhero, :create, as: "superhero")
      end

    assign(socket, form: to_form(form))
  end

  # Convert powers from textarea string to array
  defp parse_powers(%{"powers" => powers} = params) when is_binary(powers) do
    powers_array =
      powers
      |> String.split("\n")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    Map.put(params, "powers", powers_array)
  end

  defp parse_powers(params), do: params

  defp return_path("index", _superhero), do: ~p"/superheroes"
  defp return_path("show", superhero), do: ~p"/superheroes/#{superhero.id}"
end
