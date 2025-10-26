defmodule SuperheroDispatch.Dispatch.Changes.CopyHeroDataToAssignment do
  @moduledoc """
  Copies superhero data from the cached hero record to the assignment attributes.
  This denormalizes hero data onto the assignment for historical tracking purposes.

  Expects the hero to be available in changeset context (set by FetchAndCacheRelatedRecords).
  """
  use Ash.Resource.Change

  @impl true
  def change(changeset, _opts, _context) do
    case changeset.context[:hero] do
      nil ->
        changeset

      hero ->
        Ash.Changeset.change_attributes(changeset, %{
          superhero_name: hero.name,
          superhero_alias: hero.hero_alias
        })
    end
  end
end
