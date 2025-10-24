defmodule SuperheroDispatch.Dispatch.Changes.ArchiveAllAssignmentsOnClose do
  @moduledoc """
  Archives all active assignments for an incident when it is being closed.
  This ensures that all heroes assigned to the incident are freed up.
  """
  use Ash.Resource.Change
  require Ash.Query
  require Logger

  @impl true
  def change(changeset, _opts, _context) do
    incident_id = changeset.data.id

    assignments =
      SuperheroDispatch.Dispatch.Assignment
      |> Ash.Query.filter(incident_id == ^incident_id and is_nil(archived_at))
      |> Ash.read!(authorize?: false)

    Logger.info(
      "Closing incident #{incident_id}: archiving #{length(assignments)} active assignment(s)"
    )

    Enum.each(assignments, fn assignment ->
      SuperheroDispatch.Dispatch.delete_assignment!(assignment)
    end)

    changeset
  end
end
