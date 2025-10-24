defmodule SuperheroDispatch.Dispatch.Changes.UpdateHeroAndIncidentOnUnassignment do
  @moduledoc """
  After-action change that updates the superhero status to 'available' and
  recalculates the hero count on the incident after an assignment is destroyed.
  """
  use Ash.Resource.Change
  require Logger

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn changeset, assignment ->
      original_status = changeset.context[:original_status]

      if original_status && original_status not in [:assigned, :completed] do
        Logger.warning(
          "Archiving assignment #{assignment.id} with status #{inspect(original_status)}. " <>
            "Hero #{assignment.superhero_alias} was #{inspect(original_status)} when removed."
        )
      end

      SuperheroDispatch.Dispatch.mark_superhero_available!(assignment.superhero_id)

      incident = SuperheroDispatch.Dispatch.get_incident!(assignment.incident_id)

      incident
      |> Ash.Changeset.for_update(:hero_count)
      |> Ash.update!(authorize?: false)

      {:ok, assignment}
    end)
  end
end
