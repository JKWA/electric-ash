# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias SuperheroDispatch.Dispatch
alias SuperheroDispatch.Repo

# Clear existing data
IO.puts("Clearing existing data...")

# Using Ecto to truncate tables since we don't have delete_all in code interfaces yet
Repo.delete_all(SuperheroDispatch.Dispatch.Assignment)
Repo.delete_all(SuperheroDispatch.Dispatch.Incident)
Repo.delete_all(SuperheroDispatch.Dispatch.Superhero)

IO.puts("✓ Cleared existing data")

# Create Superheroes using Ash code interfaces
IO.puts("Creating superheroes...")

Dispatch.create_superhero!(
  "Diana Prince",
  "Wonder Woman",
  %{
    powers: ["Super Strength", "Flight", "Combat Skills", "Lasso of Truth"],
    current_location: "Themyscira Embassy"
  }
)

Dispatch.create_superhero!(
  "Barry Allen",
  "The Flash",
  %{
    powers: ["Super Speed", "Time Travel", "Phase Through Objects"],
    current_location: "Central City"
  }
)

Dispatch.create_superhero!(
  "Bruce Wayne",
  "Batman",
  %{
    powers: ["Detective Skills", "Martial Arts", "Gadgets", "Tactics"],
    current_location: "Wayne Manor"
  }
)

Dispatch.create_superhero!(
  "Clark Kent",
  "Superman",
  %{
    powers: ["Super Strength", "Flight", "Heat Vision", "X-Ray Vision", "Invulnerability"],
    current_location: "Downtown Metropolis"
  }
)

Dispatch.create_superhero!(
  "Hal Jordan",
  "Green Lantern",
  %{
    powers: ["Energy Constructs", "Flight", "Force Fields"],
    current_location: "Coast City"
  }
)

IO.puts("✓ Created 5 superheroes")

# Create Incidents using Ash code interfaces
IO.puts("Creating incidents...")

Dispatch.create_incident!(
  "INC-2025-001",
  "Fire",
  "Large warehouse fire spreading rapidly",
  "1234 Industrial Blvd, Metropolis",
  %{priority: :critical}
)

Dispatch.create_incident!(
  "INC-2025-002",
  "Robbery",
  "Bank robbery in progress, armed suspects",
  "First National Bank, 567 Main St",
  %{priority: :high}
)

Dispatch.create_incident!(
  "INC-2025-003",
  "Rescue",
  "Building collapse with civilians trapped",
  "Construction site, 890 Oak Avenue",
  %{priority: :critical}
)

Dispatch.create_incident!(
  "INC-2025-004",
  "Traffic Accident",
  "Multi-vehicle collision on highway",
  "Interstate 5, Mile Marker 45",
  %{priority: :medium}
)

Dispatch.create_incident!(
  "INC-2025-005",
  "Disturbance",
  "Suspicious activity reported in park",
  "Central Park, near fountain",
  %{priority: :low}
)

Dispatch.create_incident!(
  "INC-2025-006",
  "Medical Emergency",
  "Mass casualty incident at stadium",
  "Metro Stadium, Gate C",
  %{priority: :high}
)

IO.puts("✓ Created 6 incidents")

IO.puts("\n✅ Seed data created successfully!")
