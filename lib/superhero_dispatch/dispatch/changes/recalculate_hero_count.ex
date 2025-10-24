defmodule SuperheroDispatch.Dispatch.Changes.RecalculateHeroCount do
  @moduledoc """
  Recalculates the hero_count for an incident by counting active (non-archived) assignments.
  This change can be used by both Incident and Assignment actions to keep the count in sync.
  """
  use Ash.Resource.Change
  require Ash.Query

  @impl true
  def change(changeset, _opts, _context) do
    incident_id = changeset.data.id

    count =
      SuperheroDispatch.Dispatch.Assignment
      |> Ash.Query.filter(incident_id == ^incident_id and is_nil(archived_at))
      |> Ash.read!(authorize?: false)
      |> Enum.count()

    Ash.Changeset.change_attribute(changeset, :hero_count, count)
  end
end
