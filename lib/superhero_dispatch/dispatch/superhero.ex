defmodule SuperheroDispatch.Dispatch.Superhero do
  use Ash.Resource,
    domain: SuperheroDispatch.Dispatch,
    data_layer: AshPostgres.DataLayer

  postgres do
    table("superheroes")
    repo(SuperheroDispatch.Repo)
  end

  attributes do
    uuid_primary_key(:id)

    attribute :name, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :hero_alias, :string do
      allow_nil?(false)
      public?(true)
    end

    attribute :powers, {:array, :string} do
      default([])
      allow_nil?(false)
      public?(true)
    end

    attribute :status, :atom do
      constraints(one_of: [:available, :unavailable, :dispatched])
      default(:available)
      allow_nil?(false)
      public?(true)
    end

    attribute :current_location, :string do
      public?(true)
    end

    create_timestamp(:inserted_at)
    update_timestamp(:updated_at)
  end

  relationships do
    has_many :assignments, SuperheroDispatch.Dispatch.Assignment do
      destination_attribute(:superhero_id)
    end
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      primary? true
      accept [:name, :hero_alias, :powers, :current_location]
    end

    update :update do
      primary? true
      accept [:name, :hero_alias, :powers, :current_location]
    end

    update :mark_dispatched do
      accept([])

      validate(attribute_equals(:status, :available),
        message: "Can only dispatch available heroes"
      )

      change(set_attribute(:status, :dispatched))
    end

    update :mark_available do
      accept([])

      validate(attribute_equals(:status, :dispatched),
        message: "Can only mark dispatched hero as available"
      )

      change(set_attribute(:status, :available))
    end

    update :mark_unavailable do
      accept([])

      validate(attribute_equals(:status, :available),
        message: "Can only mark available heroes as unavailable"
      )

      change(set_attribute(:status, :unavailable))
    end

    update :return_to_duty do
      accept([])

      validate(attribute_equals(:status, :unavailable),
        message: "Only unavailable heroes can return to duty"
      )

      change(set_attribute(:status, :available))
    end
  end
end
