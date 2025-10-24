defmodule SuperheroDispatch.Dispatch.Changes.UpdateHeroAndIncidentOnAssignment do
  @moduledoc """
  After-action change that updates the superhero status to 'dispatched' and
  recalculates the hero count on the incident after an assignment is created.
  """
  use Ash.Resource.Change
  require Logger

  @impl true
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, fn _changeset, assignment ->
      SuperheroDispatch.Dispatch.mark_superhero_dispatched!(assignment.superhero_id)

      Logger.info("Updating hero count for incident: #{assignment.incident_id}")

      incident = SuperheroDispatch.Dispatch.get_incident!(assignment.incident_id)

      incident
      |> Ash.Changeset.for_update(:hero_count)
      |> Ash.update!(authorize?: false)

      {:ok, assignment}
    end)
  end
end
