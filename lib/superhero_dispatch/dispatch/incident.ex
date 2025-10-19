defmodule SuperheroDispatch.Dispatch.Incident do
  use Ash.Resource,
    domain: SuperheroDispatch.Dispatch,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("incidents")
    repo(SuperheroDispatch.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :incident_number, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :incident_type, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :description, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :location, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :priority, :atom do
      constraints(one_of: [:low, :medium, :high, :critical])
      default(:medium)
      allow_nil?(false)
      public?(true)
    end

    attribute :status, :atom do
      constraints(one_of: [:reported, :dispatched, :in_progress, :resolved, :closed])
      default(:reported)
      allow_nil?(false)
      public?(true)
    end

    attribute :reported_at, :utc_datetime_usec do
      allow_nil?(false)
      default(&DateTime.utc_now/0)
      public?(true)
    end

    attribute :dispatched_at, :utc_datetime_usec do
      public?(true)
    end

    attribute :resolved_at, :utc_datetime_usec do
      public?(true)
    end

    attribute :closed_at, :utc_datetime_usec do
      public?(true)
    end

    attribute :hero_count, :integer do
      default(0)
      allow_nil?(false)
      public?(true)
    end

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  relationships do
    has_many :assignments, SuperheroDispatch.Dispatch.Assignment do
      destination_attribute(:incident_id)
    end
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      primary?(true)
      accept([:incident_number, :incident_type, :description, :location, :priority])
    end

    update :update do
      primary?(true)
      accept([:incident_type, :description, :location, :priority, :status])
    end

    update :mark_dispatched do
      accept([])
      change(set_attribute(:status, :dispatched))
      change(set_attribute(:dispatched_at, expr(now())))
    end

    update :mark_in_progress do
      accept([])
      change(set_attribute(:status, :in_progress))
    end

    update :mark_resolved do
      accept([])
      change(set_attribute(:status, :resolved))
      change(set_attribute(:resolved_at, expr(now())))
    end

    update :mark_closed do
      require_atomic? false
      accept([])

      change fn changeset, _ctx ->
        incident_id = changeset.data.id
        require Ash.Query
        require Logger

        # Archive all active assignments for this incident
        assignments =
          SuperheroDispatch.Dispatch.Assignment
          |> Ash.Query.filter(incident_id == ^incident_id and is_nil(archived_at))
          |> Ash.read!(authorize?: false)

        Logger.info(
          "Closing incident #{incident_id}: archiving #{length(assignments)} active assignment(s)"
        )

        # Archive each assignment - fail if any fail
        result =
          Enum.reduce_while(assignments, :ok, fn assignment, _acc ->
            case SuperheroDispatch.Dispatch.delete_assignment(assignment) do
              {:ok, _} ->
                {:cont, :ok}

              {:error, error} ->
                Logger.error(
                  "Failed to archive assignment #{assignment.id} for incident #{incident_id}: #{inspect(error)}"
                )

                {:halt, {:error, error}}
            end
          end)

        case result do
          :ok ->
            changeset

          {:error, error} ->
            Ash.Changeset.add_error(changeset, error)
        end
      end

      change(set_attribute(:status, :closed))
      change(set_attribute(:closed_at, &DateTime.utc_now/0))

      change after_action(fn _changeset, incident, _ctx ->
               # Explicitly set hero_count to 0 after all assignments are archived
               incident
               |> Ash.Changeset.for_update(:update, %{})
               |> Ash.Changeset.force_change_attribute(:hero_count, 0)
               |> Ash.update!(authorize?: false)

               {:ok, incident}
             end)
    end

    update :reopen do
      accept([])

      validate(attribute_equals(:status, :closed), message: "Can only reopen closed incidents")

      change(set_attribute(:status, :reported))
      change(set_attribute(:closed_at, nil))
    end

    update :hero_count do
      require_atomic?(false)
      accept([])

      change fn changeset, _ ->
        incident_id = changeset.data.id
        require Ash.Query

        count =
          SuperheroDispatch.Dispatch.Assignment
          |> Ash.Query.filter(incident_id == ^incident_id and is_nil(archived_at))
          |> Ash.read!(authorize?: false)
          |> Enum.count()

        Ash.Changeset.change_attribute(changeset, :hero_count, count)
      end
    end
  end
end
