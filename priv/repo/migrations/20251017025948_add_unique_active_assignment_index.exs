defmodule SuperheroDispatch.Repo.Migrations.AddUniqueActiveAssignmentIndex do
  use Ecto.Migration

  use Ecto.Migration

  def up do
    execute("""
    CREATE UNIQUE INDEX unique_active_assignment_per_superhero
    ON assignments(superhero_id)
    WHERE status != 'completed'
    """)
  end

  def down do
    execute("""
    DROP INDEX IF EXISTS unique_active_assignment_per_superhero
    """)
  end
end
