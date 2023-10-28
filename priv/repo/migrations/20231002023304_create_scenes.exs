defmodule Core.Repo.Migrations.CreateInteractions do
  use Ecto.Migration

  def change do
    create(table(:scenes)) do
      timestamps()
    end
  end
end
