defmodule SuperheroDispatchWeb.SuperheroLive.Show do
  use SuperheroDispatchWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Superhero {@superhero.id}
        <:subtitle>This is a superhero record from your database.</:subtitle>

        <:actions>
          <.button navigate={~p"/superheroes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/superheroes/#{@superhero}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit Superhero
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Id">{@superhero.id}</:item>

        <:item title="Name">{@superhero.name}</:item>

        <:item title="Hero alias">{@superhero.hero_alias}</:item>

        <:item title="Powers">{Enum.join(@superhero.powers, ", ")}</:item>

        <:item title="Status">{@superhero.status}</:item>

        <:item title="Current location">{@superhero.current_location}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Superhero")
     |> assign(:superhero, Ash.get!(SuperheroDispatch.Dispatch.Superhero, id))}
  end
end
