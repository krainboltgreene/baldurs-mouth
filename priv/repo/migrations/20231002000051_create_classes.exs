defmodule Core.Repo.Migrations.CreateClasses do
  use Ecto.Migration

  def change do
    create(table(:classes)) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
      add(:levels, :jsonb, null: false)
      add(:saving_throw_proficiencies, {:array, :text}, null: false)
      add(:hit_dice, :integer, null: false)
    end

    create(unique_index(:classes, [:slug]))
  end
end
