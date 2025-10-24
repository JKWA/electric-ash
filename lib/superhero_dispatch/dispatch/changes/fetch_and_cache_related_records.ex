defmodule SuperheroDispatch.Dispatch.Changes.FetchAndCacheRelatedRecords do
  @moduledoc """
  Fetches and caches the superhero and incident records in the changeset context.
  This allows subsequent validations and changes to access these records without
  redundant database queries.
  """
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    superhero_id = Ash.Changeset.get_attribute(changeset, :superhero_id)
    incident_id = Ash.Changeset.get_attribute(changeset, :incident_id)

    changeset =
      case SuperheroDispatch.Dispatch.get_superhero(superhero_id) do
        {:ok, hero} ->
          Ash.Changeset.put_context(changeset, :hero, hero)

        _ ->
          changeset
      end

    changeset =
      case SuperheroDispatch.Dispatch.get_incident(incident_id) do
        {:ok, incident} ->
          Ash.Changeset.put_context(changeset, :incident, incident)

        _ ->
          changeset
      end

    changeset
  end
end
