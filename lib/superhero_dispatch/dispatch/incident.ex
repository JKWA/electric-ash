defmodule SuperheroDispatch.Dispatch.Incident do
  use Ash.Resource,
    domain: SuperheroDispatch.Dispatch,
    data_layer: AshPostgres.DataLayer

  alias SuperheroDispatch.Dispatch.Changes.{
    ArchiveAllAssignmentsOnClose,
    ResetHeroCountOnClose,
    RecalculateHeroCount
  }

  postgres do
    table("incidents")
    repo(SuperheroDispatch.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :incident_number, :string do
      allow_nil? false
      public? true
    end

    attribute :incident_type, :string do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      allow_nil? false
      public? true
    end

    attribute :location, :string do
      allow_nil? false
      public? true
    end

    attribute :priority, :atom do
      constraints one_of: [:low, :medium, :high, :critical]
      default :medium
      allow_nil? false
      public? true
    end

    attribute :status, :atom do
      constraints one_of: [:reported, :dispatched, :in_progress, :resolved, :closed]
      default :reported
      allow_nil? false
      public? true
    end

    attribute :reported_at, :utc_datetime_usec do
      allow_nil? false
      default &DateTime.utc_now/0
      public? true
    end

    attribute :dispatched_at, :utc_datetime_usec do
      public? true
    end

    attribute :resolved_at, :utc_datetime_usec do
      public? true
    end

    attribute :closed_at, :utc_datetime_usec do
      public? true
    end

    attribute :hero_count, :integer do
      default 0
      allow_nil? false
      public? true
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :assignments, SuperheroDispatch.Dispatch.Assignment do
      destination_attribute(:incident_id)
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:incident_number, :incident_type, :description, :location, :priority]
    end

    update :update do
      primary? true
      accept [:incident_type, :description, :location, :priority]
    end

    update :mark_dispatched do
      accept []
      change set_attribute(:status, :dispatched)
      change set_attribute(:dispatched_at, &DateTime.utc_now/0)
    end

    update :mark_in_progress do
      accept []

      validate attribute_equals(:status, :dispatched),
        message: "Can only mark dispatched incidents as in progress"

      change set_attribute(:status, :in_progress)
    end

    update :mark_resolved do
      accept []

      validate attribute_equals(:status, :in_progress),
        message: "Can only mark in-progress incidents as resolved"

      change set_attribute(:status, :resolved)
      change set_attribute(:resolved_at, &DateTime.utc_now/0)
    end

    update :mark_closed do
      require_atomic? false
      accept []

      change ArchiveAllAssignmentsOnClose

      change set_attribute(:status, :closed)
      change set_attribute(:closed_at, &DateTime.utc_now/0)

      change ResetHeroCountOnClose
    end

    update :reopen do
      accept []

      change set_attribute(:status, :reported)
      change set_attribute(:closed_at, nil)
    end

    update :hero_count do
      require_atomic? false
      accept []

      change RecalculateHeroCount
    end
  end
end
