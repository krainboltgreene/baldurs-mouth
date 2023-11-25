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
    Application.app_dir(:core, "priv/data/classes.yaml")
    |> YamlElixir.read_all_from_file!()
    |> Enum.map(&Utilities.Map.atomize_keys/1)
    |> Enum.map(&Core.Gameplay.create_class!/1)

    Application.app_dir(:core, "priv/data/features.yaml")
    |> YamlElixir.read_all_from_file!()
    |> Enum.map(&Utilities.Map.atomize_keys/1)
    |> Enum.map(&Core.Content.create_tag!/1)

    Application.app_dir(:core, "priv/data/items.yaml")
    |> YamlElixir.read_all_from_file!()
    |> Enum.map(&Utilities.Map.atomize_keys/1)
    |> Enum.map(&Core.Gameplay.create_item!/1)

    Application.app_dir(:core, "priv/data/spells.yaml")
    |> YamlElixir.read_all_from_file!()
    |> Enum.map(&Utilities.Map.atomize_keys/1)
    |> Enum.map(&Core.Gameplay.create_spell!/1)

    Application.app_dir(:core, "priv/data/backgrounds.yaml")
    |> YamlElixir.read_all_from_file!()
    |> Enum.map(&Utilities.Map.atomize_keys/1)
    |> Enum.map(&Core.Gameplay.create_background!/1)

    Application.app_dir(:core, "priv/data/npcs.yaml")
    |> YamlElixir.read_all_from_file!()
    |> Enum.map(&Utilities.Map.atomize_keys/1)
    |> Enum.map(&Core.Gameplay.create_npc!/1)

    Application.app_dir(:core, "priv/data/lineage_categories.yaml")
    |> YamlElixir.read_all_from_file!()
    |> Enum.map(&Core.Gameplay.create_lineage_category!/1)

    Application.app_dir(:core, "priv/data/lineages.yaml")
    |> YamlElixir.read_all_from_file!()
    |> Enum.map(&Utilities.Map.atomize_keys/1)
    |> Enum.map(fn
      %{lineage_category: lineage_category} = lineage ->
        lineage
        |> Map.put(:lineage_category, Core.Gameplay.get_lineage_category_by_slug!(lineage_category))
        |> Core.Gameplay.create_lineage!()
      lineage ->
        Core.Gameplay.create_lineage!(lineage)
    end)

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

    _purchasing_a_room_scene =
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

    _haggling_win_a_room_scene =
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

    _opening_scene =
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
