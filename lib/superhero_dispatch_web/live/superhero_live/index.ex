defmodule SuperheroDispatchWeb.SuperheroLive.Index do
  use SuperheroDispatchWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Superheroes
        <:actions>
          <.button variant="primary" navigate={~p"/superheroes/new"}>
            <.icon name="hero-plus" /> New Superhero
          </.button>
        </:actions>
      </.header>

      <.table
        id="superheroes"
        rows={@streams.superheroes}
        row_click={fn {_id, superhero} -> JS.navigate(~p"/superheroes/#{superhero}") end}
      >
        <:col :let={{_id, superhero}} label="Id">{superhero.id}</:col>

        <:col :let={{_id, superhero}} label="Name">{superhero.name}</:col>

        <:col :let={{_id, superhero}} label="Hero alias">{superhero.hero_alias}</:col>

        <:col :let={{_id, superhero}} label="Powers">{superhero.powers}</:col>

        <:col :let={{_id, superhero}} label="Status">{superhero.status}</:col>

        <:col :let={{_id, superhero}} label="Current location">{superhero.current_location}</:col>

        <:action :let={{_id, superhero}}>
          <div class="sr-only">
            <.link navigate={~p"/superheroes/#{superhero}"}>Show</.link>
          </div>

          <.link navigate={~p"/superheroes/#{superhero}/edit"}>Edit</.link>
        </:action>

        <:action :let={{id, superhero}}>
          <.link
            phx-click={JS.push("delete", value: %{id: superhero.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Superheroes")
     |> stream(:superheroes, Ash.read!(SuperheroDispatch.Dispatch.Superhero))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    superhero = Ash.get!(SuperheroDispatch.Dispatch.Superhero, id)
    Ash.destroy!(superhero)

    {:noreply, stream_delete(socket, :superheroes, superhero)}
  end
end
