defmodule SuperheroDispatch.Dispatch.Assignment do
  use Ash.Resource,
    domain: SuperheroDispatch.Dispatch,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  require Logger

  postgres do
    table("assignments")
    repo(SuperheroDispatch.Repo)
  end

  archive do
    exclude_read_actions([:archived])
  end

  attributes do
    uuid_primary_key(:id)

    attribute :status, :atom do
      constraints(one_of: [:assigned, :en_route, :on_scene, :completed])
      default(:assigned)
      allow_nil?(false)
      public?(true)
    end

    attribute :superhero_name, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :superhero_alias, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :superhero_status, :atom do
      constraints(one_of: [:dispatched])
      default(:dispatched)
      allow_nil?(false)
      public?(true)
    end

    attribute :notes, :string do
      public?(true)
    end

    attribute :assigned_at, :utc_datetime_usec do
      allow_nil?(false)
      default(&DateTime.utc_now/0)
      public?(true)
    end

    attribute :arrived_at, :utc_datetime_usec do
      public?(true)
    end

    attribute :completed_at, :utc_datetime_usec do
      public?(true)
    end

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  relationships do
    belongs_to :superhero, SuperheroDispatch.Dispatch.Superhero do
      allow_nil?(false)
      attribute_writable?(true)
    end

    belongs_to :incident, SuperheroDispatch.Dispatch.Incident do
      allow_nil?(false)
      attribute_writable?(true)
    end
  end

  actions do
    defaults([:read])

    create :create do
      accept([
        :notes,
        :superhero_id,
        :incident_id
      ])

      validate fn changeset, _ ->
        case SuperheroDispatch.Dispatch.get_superhero(
               Ash.Changeset.get_attribute(changeset, :superhero_id)
             ) do
          {:ok, hero} ->
            if hero.status == :available do
              :ok
            else
              {:error, field: :superhero_id, message: "Hero must be available to be assigned. Current status: #{hero.status}"}
            end

          _ ->
            {:error, field: :superhero_id, message: "Hero not found"}
        end
      end

      change fn changeset, _ ->
        case SuperheroDispatch.Dispatch.get_superhero(
               Ash.Changeset.get_attribute(changeset, :superhero_id)
             ) do
          {:ok, hero} ->
            Ash.Changeset.change_attributes(changeset, %{
              superhero_name: hero.name,
              superhero_alias: hero.hero_alias,
              superhero_status: :dispatched
            })

          _ ->
            changeset
        end
      end

      change after_action(fn _changeset, assignment, _ctx ->
               if assignment.superhero_id do
                 SuperheroDispatch.Dispatch.mark_superhero_dispatched!(assignment.superhero_id)
               end

               Logger.info("Updating hero count for incident: #{assignment.incident_id}")

               incident = SuperheroDispatch.Dispatch.get_incident!(assignment.incident_id)

               incident
               |> Ash.Changeset.for_update(:hero_count)
               |> Ash.update!(authorize?: false)

               {:ok, assignment}
             end)
    end

    update :update do
      primary? true
      accept([:superhero_status, :notes])
    end

    update :mark_en_route do
      accept([])
      change(set_attribute(:status, :en_route))
    end

    update :mark_on_scene do
      accept([])
      change(set_attribute(:status, :on_scene))
      change(set_attribute(:arrived_at, DateTime.utc_now()))
    end

    update :mark_completed do
      accept([:notes])
      change(set_attribute(:status, :completed))
      change(set_attribute(:completed_at, DateTime.utc_now()))
    end

    destroy :destroy do
      require_atomic? false
      soft? true

      change set_attribute(:archived_at, &DateTime.utc_now/0)

      change after_action(fn _changeset, assignment, _ctx ->
               if assignment.superhero_id do
                 SuperheroDispatch.Dispatch.mark_superhero_available!(assignment.superhero_id)
               end

               incident = SuperheroDispatch.Dispatch.get_incident!(assignment.incident_id)

               incident
               |> Ash.Changeset.for_update(:hero_count)
               |> Ash.update!(authorize?: false)

               {:ok, assignment}
             end)
    end
  end
end
