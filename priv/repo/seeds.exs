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

{:ok, _} =
  Core.Repo.transaction(fn ->
    {:ok, narrator} =
      Core.Theater.create_npc(%{
        name: "Narrator",
        known: true
      })

    {:ok, gritford} =
      Core.Theater.create_npc(%{
        name: "Gritford Bellyforge"
      })

    {:ok, _} =
      Core.Gameplay.create_background(%{
        name: "Folk Hero",
        forced_skills: [
          "animal-handling",
          "survival"
        ],
        selectable_skills: [],
        skill_choices: 0,
        forced_tools: [],
        tool_choices: 1,
        selectable_tools: ["gaming", "musical"]
      })

    {:ok, _} =
      Core.Gameplay.create_background(%{
        name: "Failed Merchant"
      })

    {:ok, _} =
      Core.Gameplay.create_background(%{
        name: "Acolyte"
      })

    {:ok, elf_lineage_category} =
      Core.Gameplay.create_lineage_category(%{
        name: "Elf"
      })

    {:ok, tiefling_lineage_category} =
      Core.Gameplay.create_lineage_category(%{
        name: "Tiefling"
      })

    {:ok, _} =
      Core.Gameplay.create_lineage(%{
        name: "High-Elf",
        lineage_category: elf_lineage_category
      })

    {:ok, _} =
      Core.Gameplay.create_lineage(%{
        name: "Half-Orc"
      })

    {:ok, _} =
      Core.Gameplay.create_lineage(%{
        name: "Asmodeous Tiefling",
        lineage_category: tiefling_lineage_category
      })

    {:ok, _} =
      Core.Gameplay.create_class(%{
        name: "Paladin",
        hit_dice: 10,
        saving_throw_proficiencies: [
          "wisdom",
          "charisma"
        ],
        spellcasting_ability: "charisma"
      })

    {:ok, _} =
      Core.Gameplay.create_class(%{
        name: "Fighter",
        hit_dice: 10,
        saving_throw_proficiencies: [
          "strength",
          "constitution"
        ]
      })

    {:ok, _} =
      Core.Gameplay.create_class(%{
        name: "Bard",
        hit_dice: 8,
        saving_throw_proficiencies: [
          "dexterity",
          "charisma"
        ],
        spellcasting_ability: "charisma"
      })

    {:ok, _} =
      Core.Gameplay.create_class(%{
        name: "Wizard",
        hit_dice: 6,
        saving_throw_proficiencies: [
          "intelligence",
          "wisdom"
        ],
        spellcasting_ability: "intelligence"
      })

    {:ok, _} =
      Core.Gameplay.create_item(%{
        name: "Greatsword",
        tags: ["martial-weapons"]
      })

    {:ok, campaign} =
      Core.Content.create_campaign(%{
        name: "Ill-Omens at Daggerford"
      })

    {:ok, opening_scene} =
      Core.Theater.create_scene(%{
        campaign: campaign,
        opening: true,
        name: "Entering Lucky Fox Tavern For The First Time"
      })

    {:ok, _} =
      Core.Theater.create_line(%{
        speaker_npc: narrator,
        scene: opening_scene,
        body:
          "As you approach the bar the pudgy tavern keep looks up, clearly happy to see the new guests."
      })

    {:ok, _} =
      Core.Theater.create_line(%{
        speaker_npc: gritford,
        scene: opening_scene,
        body:
          "Hello there, welcome to the Lucky Fox! We have one small room open, but it's only got one bed. What can I do for you?"
      })

    {:ok, _} =
      Core.Theater.create_line(%{
        speaker_npc: narrator,
        scene: opening_scene,
        body:
          "Directly above the tavern keeper is a small eye carved into the wood. It's the symbol for the Guild's membership. He is either a part of the guild or a pawn."
      })

    {:ok, _} =
      Core.Theater.create_dialogue(%{
        for_scene: opening_scene,
        body: "Yes, we'd like one room please."
      })

    {:ok, _} =
      Core.Theater.create_dialogue(%{
        for_scene: opening_scene,
        body:
          "Actually, we're wondering if there's another inn near by? This place seems rather...damp."
      })

    {:ok, _} =
      Core.Theater.create_dialogue(%{
        for_scene: opening_scene,
        challenge: %{
          type: "required",
          track: "tavern_keeper_secret_basement",
          state: "known_guild_participant",
          language: "thieves_cant"
        },
        body: "Oh, are you a part of the Guild?"
      })

    {:ok, _} =
      Core.Theater.create_dialogue(%{
        for_scene: opening_scene,
        challenge: %{
          type: "required",
          track: "tavern_keeper_secret_basement",
          state: "known_guild_participant",
          language: "thieves_cant"
        },
        body: "We'd like to see where the fox sleeps."
      })

    {:ok, _} =
      Core.Theater.create_dialogue(%{
        for_scene: opening_scene,
        challenge: %{
          type: "required",
          track: "tavern_keeper_secret_basement",
          state: "discovered_note"
        },
        body: "We're looking to get into that basement of yours, what's the price?"
      })

    {:ok, _} =
      Core.Theater.create_dialogue(%{
        for_scene: opening_scene,
        challenge: %{
          type: "optional",
          skill: "deception",
          target: 18
        },
        body: "By right of eminent domain from the City Guard captain we are to have two rooms!"
      })
  end)
