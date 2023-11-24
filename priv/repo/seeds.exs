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
    Core.Gameplay.create_feature(%{
      name: "Darkvision",
      description: """
      Thanks to your orc blood, you have superior vision in dark and dim conditions. You can see in dim light within 60 feet of you as if it were bright light, and in darkness as if it were dim light. You can’t discern color in darkness, only shades of gray.
      """
    })

    Core.Gameplay.create_feature(%{
      name: "Menacing",
      description: """
      You gain proficiency in the Intimidation skill.
      """
    })

    Core.Gameplay.create_feature(%{
      name: "Savage Attack",
      description: """
      When you score a critical hit with a melee weapon attack, you can roll one of the weapon’s damage dice one additional time and add it to the extra damage of the critical hit.
      """
    })

    Core.Gameplay.create_feature(%{
      name: "Relentless Endurance",
      description: """
      When you are reduced to 0 hit points but not killed outright, you can drop to 1 hit point instead. You can’t use this feature again until you finish a long rest.
      """
    })

    Core.Gameplay.create_feature(%{
      name: "Rustic Hospitality",
      description: """
      Since you come from the ranks of the common folk, you fit in among them with ease. You can find a place to hide, rest, or recuperate among other commoners, unless you have shown yourself to be a danger to them. They will shield you from the law or anyone else searching for you, though they will not risk their lives for you.
      """
    })

    Core.Gameplay.create_feature(%{
      name: "Scarred And Strong",
      description: """
      Half-orcs exhibit a blend of orcish and human characteristics, and their appearance varies widely. Grayish skin tones and prominent teeth are the most common shared elements among these folk.

      Orcs regard battle scars as tokens of pride and ornamental scars as things of beauty. Other scars, though, mark an orc or half-orc as a former prisoner or a disgraced exile. Any half-orc who has lived among or near orcs has scars, whether they are marks of humiliation or of pride, recounting their past exploits and injuries.
      """
    })

    Core.Gameplay.create_feature(%{
      name: "Mark of Gruumsh",
      description: """
      The one-eyed god Gruumsh—lord of war and fury—created the first orcs, and even those orcs who turn away from his worship carry his blessings of might and endurance. The same is true of half-orcs. Some half-orcs hear the whispers of Gruumsh in their dreams, calling them to unleash the rage that simmers within them. Others feel Gruumsh's exultation when they join in melee combat — and either exult along with him or shiver with fear and loathing.

      Beyond the rage of Gruumsh, half-orcs feel emotion powerfully. Rage doesn't just quicken their pulse, it makes their bodies burn. An insult stings like acid, and sadness saps their strength. But they laugh loudly and heartily, and simple pleasures — feasting, drinking, wrestling, drumming, and wild dancing — fill their hearts with joy. They tend to be short-tempered and sometimes sullen, more inclined to action than contemplation and to fighting than arguing. And when their hearts swell with love, they leap to perform acts of great kindness and compassion.
      """
    })

    Core.Gameplay.create_background!(%{
      name: "Folk Hero",
      description: """
      You come from a humble social rank, but you are destined for so much more. Already the people of your home village regard you as their champion, and your destiny calls you to stand against the tyrants and monsters that threaten the common folk everywhere.

      You previously pursued a simple profession among the peasantry, perhaps as a farmer, miner, servant, shepherd, woodcutter, or gravedigger. But something happened that set you on a different path and marked you for greater things. Choose or randomly determine a defining event that marked you as a hero of the people.
      """
    })

    Core.Gameplay.create_background!(%{
      name: "Failed Merchant",
      description: "Lorem ipsum"
    })

    Core.Gameplay.create_background!(%{
      name: "Acolyte",
      description: "Lorem ipsum"
    })

    elf_lineage_category =
      Core.Gameplay.create_lineage_category!(%{
        name: "Elf"
      })

    tiefling_lineage_category =
      Core.Gameplay.create_lineage_category!(%{
        name: "Tiefling",
        description: "Lorem ipsum"
      })

    Core.Gameplay.create_lineage!(%{
      name: "High-Elf",
      description: "Lorem ipsum",
      lineage_category: elf_lineage_category
    })

    Core.Gameplay.create_lineage!(%{
      name: "Half-Orc",
      description:
        "Whether united under the leadership of a mighty warlock or having fought to a standstill after years of conflict, orc and human communities, sometimes form alliances. When these alliances are sealed by marriages, half-orcs are born. Some half-orcs rise to become proud leaders of orc communities. Some venture into the world to prove their worth. Many of these become adventurers, achieving greatness for their mighty deeds."
    })

    Core.Gameplay.create_lineage!(%{
      name: "Asmodeous Tiefling",
      description: "Lorem ipsum",
      lineage_category: tiefling_lineage_category
    })

    Core.Gameplay.create_class!(%{
      name: "Paladin",
      description: "Lorem ipsum",
      hit_dice: 10,
      saving_throw_proficiencies: [
        "wisdom",
        "charisma"
      ],
      spellcasting_ability: "charisma"
    })

    Core.Gameplay.create_class!(%{
      name: "Fighter",
      description: "Lorem ipsum",
      hit_dice: 10,
      saving_throw_proficiencies: [
        "strength",
        "constitution"
      ]
    })

    Core.Gameplay.create_class!(%{
      name: "Bard",
      description: "Lorem ipsum",
      hit_dice: 8,
      saving_throw_proficiencies: [
        "dexterity",
        "charisma"
      ],
      spellcasting_ability: "charisma"
    })

    Core.Gameplay.create_class!(%{
      name: "Wizard",
      description: "Lorem ipsum",
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
            state: "known_guild_participant"
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
            tag: "thieves_cant"
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
