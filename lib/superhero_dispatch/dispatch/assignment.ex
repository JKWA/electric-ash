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

      # Fetch and cache hero and incident once for validation and changes
      change fn changeset, _ctx ->
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

      # Validate hero exists and is available
      validate fn changeset, _ ->
        case changeset.context[:hero] do
          nil ->
            {:error, field: :superhero_id, message: "Hero not found"}

          hero ->
            if hero.status == :available do
              :ok
            else
              {:error,
               field: :superhero_id,
               message: "Hero must be available to be assigned. Current status: #{hero.status}"}
            end
        end
      end

      # Validate incident exists and is not closed
      validate fn changeset, _ ->
        case changeset.context[:incident] do
          nil ->
            {:error, field: :incident_id, message: "Incident not found"}

          incident ->
            if incident.status == :closed do
              {:error, field: :incident_id, message: "Cannot assign heroes to closed incidents"}
            else
              :ok
            end
        end
      end

      # Copy hero data to assignment attributes
      change fn changeset, _ctx ->
        case changeset.context[:hero] do
          nil ->
            changeset

          hero ->
            Ash.Changeset.change_attributes(changeset, %{
              superhero_name: hero.name,
              superhero_alias: hero.hero_alias,
              superhero_status: :dispatched
            })
        end
      end

      change after_action(fn _changeset, assignment, _ctx ->
               SuperheroDispatch.Dispatch.mark_superhero_dispatched!(assignment.superhero_id)

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
      accept([:notes])
    end

    update :mark_en_route do
      accept([])
      change(set_attribute(:status, :en_route))
    end

    update :mark_on_scene do
      accept([])
      change(set_attribute(:status, :on_scene))
      change(set_attribute(:arrived_at, &DateTime.utc_now/0))
    end

    update :mark_completed do
      accept([:notes])
      change(set_attribute(:status, :completed))
      change(set_attribute(:completed_at, &DateTime.utc_now/0))
    end

    destroy :destroy do
      require_atomic? false
      soft? true

      # Capture original status before we change it
      change fn changeset, _ctx ->
        original_status = changeset.data.status
        Ash.Changeset.put_context(changeset, :original_status, original_status)
      end

      change set_attribute(:archived_at, &DateTime.utc_now/0)
      change set_attribute(:status, :completed)

      change after_action(fn changeset, assignment, _ctx ->
               # Log if we're archiving a non-assigned assignment for visibility
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
end
