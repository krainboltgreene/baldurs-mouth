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
    Core.Gameplay.create_background!(%{
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

    Core.Gameplay.create_background!(%{
      name: "Failed Merchant"
    })

    Core.Gameplay.create_background!(%{
      name: "Acolyte"
    })

    elf_lineage_category =
      Core.Gameplay.create_lineage_category!(%{
        name: "Elf"
      })

    tiefling_lineage_category =
      Core.Gameplay.create_lineage_category!(%{
        name: "Tiefling"
      })

    Core.Gameplay.create_lineage!(%{
      name: "High-Elf",
      lineage_category: elf_lineage_category
    })

    Core.Gameplay.create_lineage!(%{
      name: "Half-Orc"
    })

    Core.Gameplay.create_lineage!(%{
      name: "Asmodeous Tiefling",
      lineage_category: tiefling_lineage_category
    })

    Core.Gameplay.create_class!(%{
      name: "Paladin",
      hit_dice: 10,
      saving_throw_proficiencies: [
        "wisdom",
        "charisma"
      ],
      spellcasting_ability: "charisma"
    })

    Core.Gameplay.create_class!(%{
      name: "Fighter",
      hit_dice: 10,
      saving_throw_proficiencies: [
        "strength",
        "constitution"
      ]
    })

    Core.Gameplay.create_class!(%{
      name: "Bard",
      hit_dice: 8,
      saving_throw_proficiencies: [
        "dexterity",
        "charisma"
      ],
      spellcasting_ability: "charisma"
    })

    Core.Gameplay.create_class!(%{
      name: "Wizard",
      hit_dice: 6,
      saving_throw_proficiencies: [
        "intelligence",
        "wisdom"
      ],
      spellcasting_ability: "intelligence"
    })

    Core.Gameplay.create_item!(%{
      name: "Greatsword",
      tags: ["martial-weapons"]
    })

    narrator =
      Core.Theater.create_npc!(%{
        name: "Narrator",
        known: true
      })

    grizot_npc =
      Core.Theater.create_npc!(%{
        name: "Grizot Bellyforge"
      })

    campaign =
      Core.Content.create_campaign!(%{
        name: "Ill-Omens at Daggerford"
      })

    purchasing_a_room_scene =
      Core.Theater.create_scene!(%{
        campaign: campaign,
        name: "Paying For Room & Board"
      })
      |> tap(
        &Core.Theater.add_line_to!(
          &1,
          "Oh no, you've stumbled onto a scene that hasn't been quite realized into existence. I don't think you'll be surviving this.",
          narrator
        )
      )

    the_cost_of_room_and_board_scene =
      Core.Theater.create_scene!(%{
        campaign: campaign,
        name: "The Cost of Room & Board"
      })
      |> tap(
        &Core.Theater.add_line_to!(
          &1,
          "Oh no, you've stumbled onto a scene that hasn't been quite realized into existence. I don't think you'll be surviving this.",
          narrator
        )
      )

    haggling_win_a_room_scene =
      Core.Theater.create_scene!(%{
        campaign: campaign,
        name: "Successfully Haggling the Price of Room & Board"
      })
      |> tap(
        &Core.Theater.add_line_to!(
          &1,
          "Oh no, you've stumbled onto a scene that hasn't been quite realized into existence. I don't think you'll be surviving this.",
          narrator
        )
      )

    haggling_fail_a_room_scene =
      Core.Theater.create_scene!(%{
        campaign: campaign,
        name: "Unsuccessfully Haggling the Price of Room & Board"
      })
      |> tap(
        &Core.Theater.add_line_to!(
          &1,
          "Oh no, you've stumbled onto a scene that hasn't been quite realized into existence. I don't think you'll be surviving this.",
          narrator
        )
      )

    denies_zhentarim_allegation_scene =
      Core.Theater.create_scene!(%{
        campaign: campaign,
        name: "Owner Denies Unfounded Allegation of Zhentarim Allegience"
      })
      |> tap(
        &Core.Theater.add_line_to!(
          &1,
          "Oh no, you've stumbled onto a scene that hasn't been quite realized into existence. I don't think you'll be surviving this.",
          narrator
        )
      )

    denies_existence_of_basement_scene =
      Core.Theater.create_scene!(%{
        campaign: campaign,
        name: "Owner Denies Existence of Vaunted Basement Lodgings"
      })
      |> tap(
        &Core.Theater.add_line_to!(
          &1,
          "Oh no, you've stumbled onto a scene that hasn't been quite realized into existence. I don't think you'll be surviving this.",
          narrator
        )
      )

    appreciates_zhentarim_allegation_scene =
      Core.Theater.create_scene!(%{
        campaign: campaign,
        name: "Owner Appreciates Zhentarim Connection"
      })
      |> tap(
        &Core.Theater.add_line_to!(
          &1,
          "Oh no, you've stumbled onto a scene that hasn't been quite realized into existence. I don't think you'll be surviving this.",
          narrator
        )
      )

    cedes_to_fake_demands_scene =
      Core.Theater.create_scene!(%{
        campaign: campaign,
        name: "Owner Cedes to the Citywatch Authority!"
      })
      |> tap(
        &Core.Theater.add_line_to!(
          &1,
          "Oh no, you've stumbled onto a scene that hasn't been quite realized into existence. I don't think you'll be surviving this.",
          narrator
        )
      )

    called_bluff_scene =
      Core.Theater.create_scene!(%{
        campaign: campaign,
        name: "Owner Calls Your Bluff!"
      })
      |> tap(
        &Core.Theater.add_line_to!(
          &1,
          "Oh no, you've stumbled onto a scene that hasn't been quite realized into existence. I don't think you'll be surviving this.",
          narrator
        )
      )

    opening_scene =
      Core.Theater.create_scene!(%{
        campaign: campaign,
        opening: true,
        name: "Entering Lucky Fox Tavern For The First Time"
      })
      |> tap(
        &Core.Theater.add_line_to!(
          &1,
          "As you approach the bar a pudgy tavern keep looks up from his cleaning work, clearly happy to see any new guests given the very empty room.",
          narrator
        )
      )
      |> tap(
        &Core.Theater.add_line_to!(
          &1,
          "Hello there, welcome to the Lucky Fox! We have one small room open, but it's only got one bed. What can I do for you?",
          grizot_npc
        )
      )
      |> tap(
        &Core.Theater.add_line_to!(
          &1,
          "Directly above the tavern keeper is a small dragon carved into the wood. It's the symbol for the Zhentarim's membership. He is either a part of the guild or a pawn.",
          narrator
        )
      )
      |> tap(
        &Core.Theater.add_dialogue_to!(
          &1,
          "Yes, we'd like one room please.",
          the_cost_of_room_and_board_scene
        )
      )
      |> tap(
        &Core.Theater.add_dialogue_to!(
          &1,
          "Actually, we're wondering if there's another inn near by? This place seems rather...damp."
        )
      )
      |> tap(
        &Core.Theater.add_dialogue_to!(
          &1,
          "Oh, are you a part of those Zhentarim fellows?",
          denies_zhentarim_allegation_scene,
          %{
            type: "required",
            track: "tavern_keeper_secret_basement",
            state: "known_guild_participant",
            language: "thieves_cant"
          }
        )
      )
      |> tap(
        &Core.Theater.add_dialogue_to!(
          &1,
          "We'd like to see where the fox sleeps.",
          appreciates_zhentarim_allegation_scene,
          %{
            type: "required",
            track: "tavern_keeper_secret_basement",
            state: "known_guild_participant",
            language: "thieves_cant"
          }
        )
      )
      |> tap(
        &Core.Theater.add_dialogue_to!(
          &1,
          "We're looking to get into that basement of yours, what's the price?",
          denies_existence_of_basement_scene,
          %{
            type: "required",
            track: "tavern_keeper_secret_basement",
            state: "discovered_note"
          }
        )
      )
      |> tap(
        &Core.Theater.add_dialogue_to!(
          &1,
          "The city guard said we're to have two rooms, so kick out whomever you have to!",
          cedes_to_fake_demands_scene,
          %{
            type: "optional",
            skill: "deception",
            target: 18
          },
          called_bluff_scene
        )
      )
  end)
