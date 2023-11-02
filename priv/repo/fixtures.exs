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
          pronouns: %{
            normative: "he",
            accusative: "him",
            genitive: "his",
            reflexive: "himself"
          },
          strength: 15,
          dexterity: 12,
          constitution: 14,
          inteligence: 12,
          wisdom: 9,
          charisma: 10,
          lineage: Core.Gameplay.get_lineage_by_slug!("half-orc"),
          background: Core.Gameplay.get_background_by_slug!("folk-hero"),
          lineage_choices: %{},
          background_choices: %{
            tool_proficiences: [
              "dice",
              "flute"
            ]
          }
        })

      {:ok, _level} =
        Core.Gameplay.level_up(
          svet,
          Core.Gameplay.get_class_by_slug!("fighter"),
          %{
            fighting_style: "great-weapon-fighting",
            skill_proficiencies: [
              "athletics",
              "survival"
            ]
          },
          1
        )

      {:ok, _level} =
        Core.Gameplay.level_up(
          svet,
          Core.Gameplay.get_class_by_slug!("fighter"),
          %{
            skill_proficiencies: [
              "athletics",
              "survival"
            ]
          },
          2
        )

      svet
      |> Core.Content.print_character_sheet()
      |> IO.puts()

      trade_dispute = Core.Content.get_campaign_by_slug("trade-dispute")

      Core.Theater.play(trade_dispute, [svet])
    end)
end

# Reset the log level back to normal
Logger.configure(level: previous_log_level)
