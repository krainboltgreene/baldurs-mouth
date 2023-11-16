# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Core.Repo.insert!(%Core.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

require Logger

# Capture the current log level so we can reset after
previous_log_level = Logger.level()

# Change the log level so we don't see all the debug output.
Logger.configure(level: :info)

he_him = %{
  normative: "he",
  accusative: "him",
  genitive: "his",
  reflexive: "himself"
}

she_her = %{
  normative: "she",
  accusative: "her",
  genitive: "hers",
  reflexive: "herself"
}

they_them = %{
  normative: "they",
  accusative: "them",
  genitive: "their",
  reflexive: "themself"
}

if Mix.env() == :dev do
  {:ok, _} =
    Core.Repo.transaction(fn ->
      {:ok, krainboltgreene} =
        Core.Users.register_account(%{
          name: "Kurtis Rainbolt-Greene",
          email_address: "kurtis@baldurs-mouth.com",
          username: "krainboltgreene",
          password: "passwordpassword"
        })

      {encoded_token, account_token} =
        Core.Users.AccountToken.build_email_token(krainboltgreene, "confirm")

      {:ok, _} = Core.Repo.insert(account_token)
      {:ok, _} = Core.Users.confirm_account(encoded_token)

      {:ok, josephryan} =
        Core.Users.register_account(%{
          name: "Joseph Ryan",
          email_address: "joseph.j.a.ryan@baldurs-mouth.com",
          username: "josephryan",
          password: "passwordpassword"
        })

      {encoded_token, account_token} =
        Core.Users.AccountToken.build_email_token(josephryan, "confirm")

      {:ok, _} = Core.Repo.insert(account_token)
      {:ok, _} = Core.Users.confirm_account(encoded_token)

      {:ok, svet} =
        Core.Gameplay.create_character(%{
          account: krainboltgreene,
          name: "Svet the Happy",
          pronouns: they_them,
          strength: 17,
          dexterity: 10,
          constitution: 15,
          inteligence: 10,
          wisdom: 13,
          charisma: 10,
          lineage: Core.Gameplay.get_lineage_by_slug!("half-orc"),
          background: Core.Gameplay.get_background_by_slug!("folk-hero")
        })

      svet
      |> Core.Repo.preload(levels: [:class], lineage: [lineage_category: []], background: [])
      |> tap(&Core.Gameplay.preview(&1, :lineage))
      |> tap(&Core.Gameplay.preview(&1, :background))
      |> tap(&Core.Gameplay.preview(&1, Core.Gameplay.get_class_by_slug!("fighter"), 1))
      |> tap(&Core.Gameplay.preview(&1, Core.Gameplay.get_class_by_slug!("fighter"), 2))
      |> tap(&Core.Gameplay.preview(&1, Core.Gameplay.get_class_by_slug!("fighter"), 3))

      svet
      |> Core.Repo.preload(levels: [:class], lineage: [lineage_category: []], background: [])
      |> tap(&Core.Gameplay.level_up(&1, :lineage, %{}))
      |> tap(&Core.Gameplay.level_up(&1, :background, %{}))
      |> tap(&Core.Gameplay.level_up(&1, Core.Gameplay.get_class_by_slug!("fighter"), 1, %{}))
      |> tap(&Core.Gameplay.level_up(&1, Core.Gameplay.get_class_by_slug!("fighter"), 2, %{}))
      |> tap(&Core.Gameplay.level_up(&1, Core.Gameplay.get_class_by_slug!("fighter"), 3, %{}))

      {:ok, onyeje} =
        Core.Gameplay.create_character(%{
          account: krainboltgreene,
          name: "Sweet Onyeje",
          pronouns: she_her,
          strength: 10,
          dexterity: 15,
          constitution: 8,
          inteligence: 13,
          wisdom: 12,
          charisma: 17,
          lineage: Core.Gameplay.get_lineage_by_slug!("asmodeous-tiefling"),
          background: Core.Gameplay.get_background_by_slug!("failed-merchant")
        })

      onyeje
      |> Core.Repo.preload(levels: [:class], lineage: [lineage_category: []], background: [])
      |> tap(&Core.Gameplay.preview(&1, :lineage))
      |> tap(&Core.Gameplay.preview(&1, :background))
      |> tap(&Core.Gameplay.preview(&1, Core.Gameplay.get_class_by_slug!("bard"), 1))
      |> tap(&Core.Gameplay.preview(&1, Core.Gameplay.get_class_by_slug!("bard"), 2))
      |> tap(&Core.Gameplay.preview(&1, Core.Gameplay.get_class_by_slug!("bard"), 3))

      onyeje
      |> Core.Repo.preload(levels: [:class], lineage: [lineage_category: []], background: [])
      |> tap(&Core.Gameplay.level_up(&1, :lineage, %{}))
      |> tap(&Core.Gameplay.level_up(&1, :background, %{}))
      |> tap(&Core.Gameplay.level_up(&1, Core.Gameplay.get_class_by_slug!("bard"), 1, %{}))
      |> tap(&Core.Gameplay.level_up(&1, Core.Gameplay.get_class_by_slug!("bard"), 2, %{}))
      |> tap(&Core.Gameplay.level_up(&1, Core.Gameplay.get_class_by_slug!("bard"), 3, %{}))

      {:ok, shankar} =
        Core.Gameplay.create_character(%{
          account: krainboltgreene,
          name: "Amal 'One-Eyed' Neerad",
          pronouns: he_him,
          strength: 13,
          dexterity: 10,
          constitution: 15,
          inteligence: 10,
          wisdom: 17,
          charisma: 10,
          lineage: Core.Gameplay.get_lineage_by_slug!("high-elf"),
          background: Core.Gameplay.get_background_by_slug!("acolyte")
        })

      shankar
      |> Core.Repo.preload(levels: [:class], lineage: [lineage_category: []], background: [])
      |> tap(&Core.Gameplay.preview(&1, :lineage))
      |> tap(&Core.Gameplay.preview(&1, :background))
      |> tap(&Core.Gameplay.preview(&1, Core.Gameplay.get_class_by_slug!("wizard"), 1))
      |> tap(&Core.Gameplay.preview(&1, Core.Gameplay.get_class_by_slug!("wizard"), 2))
      |> tap(&Core.Gameplay.preview(&1, Core.Gameplay.get_class_by_slug!("wizard"), 3))

      shankar
      |> Core.Repo.preload(levels: [:class], lineage: [lineage_category: []], background: [])
      |> tap(&Core.Gameplay.level_up(&1, :lineage, %{}))
      |> tap(&Core.Gameplay.level_up(&1, :background, %{}))
      |> tap(&Core.Gameplay.level_up(&1, Core.Gameplay.get_class_by_slug!("wizard"), 1, %{}))
      |> tap(&Core.Gameplay.level_up(&1, Core.Gameplay.get_class_by_slug!("wizard"), 2, %{}))
      |> tap(&Core.Gameplay.level_up(&1, Core.Gameplay.get_class_by_slug!("wizard"), 3, %{}))

      svet
      |> Core.Content.print_character_sheet()
      |> IO.puts()

      onyeje
      |> Core.Content.print_character_sheet()
      |> IO.puts()

      shankar
      |> Core.Content.print_character_sheet()
      |> IO.puts()
    end)
end

# Reset the log level back to normal
Logger.configure(level: previous_log_level)
