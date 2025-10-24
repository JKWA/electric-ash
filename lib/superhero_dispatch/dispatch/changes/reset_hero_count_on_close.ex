defmodule SuperheroDispatch.Dispatch.Changes.ResetHeroCountOnClose do
  @moduledoc """
  After-action change that explicitly sets the hero_count to 0 after closing an incident.
  This ensures the count is correct even after all assignments have been archived.
  """
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn _changeset, incident ->
      updated_incident =
        incident
        |> Ash.Changeset.for_update(:update, %{})
        |> Ash.Changeset.force_change_attribute(:hero_count, 0)
        |> Ash.update!(authorize?: false)

      {:ok, updated_incident}
    end)
  end
end
