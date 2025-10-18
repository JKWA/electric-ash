defmodule SuperheroDispatch.Dispatch do
  use Ash.Domain

  resources do
    resource SuperheroDispatch.Dispatch.Superhero do
      define(:list_superheroes, action: :read)
      define(:get_superhero, action: :read, get_by: [:id])
      define(:create_superhero, action: :create, args: [:name, :hero_alias])
      define(:update_superhero, action: :update)
      define(:delete_superhero, action: :destroy)
      define(:mark_superhero_dispatched, action: :mark_dispatched)
      define(:mark_superhero_available, action: :mark_available)
      define(:mark_superhero_unavailable, action: :mark_unavailable)
      define(:return_superhero_to_duty, action: :return_to_duty)
    end

    resource SuperheroDispatch.Dispatch.Incident do
      define(:list_incidents, action: :read)
      define(:get_incident, action: :read, get_by: [:id])

      define(:create_incident,
        action: :create,
        args: [:incident_number, :incident_type, :description, :location]
      )

      define(:update_incident, action: :update)
      define(:delete_incident, action: :destroy)
      define(:mark_incident_dispatched, action: :mark_dispatched)
      define(:mark_incident_in_progress, action: :mark_in_progress)
      define(:mark_incident_resolved, action: :mark_resolved)
      define(:mark_incident_closed, action: :mark_closed)
      define(:update_hero_count, action: :hero_count)
    end

    resource SuperheroDispatch.Dispatch.Assignment do
      define(:list_assignments, action: :read)
      define(:get_assignment, action: :read, get_by: [:id])
      define(:create_assignment, action: :create)
      define(:update_assignment, action: :update)
      define(:delete_assignment, action: :destroy)
      define(:mark_assignment_en_route, action: :mark_en_route)
      define(:mark_assignment_on_scene, action: :mark_on_scene)
      define(:mark_assignment_completed, action: :mark_completed)
    end
  end
end
