defmodule Core.Repo.Migrations.CreateClasses do
  use Ecto.Migration

  def change do
    create(table(:classes)) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
      add(:description, :text, null: false)
      add(:saving_throw_proficiencies, {:array, :text}, null: false)
      add(:hit_dice, :integer, null: false)
      add(:spellcasting_ability, :citext)
    end

    create(unique_index(:classes, [:slug]))
  end
end
