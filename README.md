# Baldur's Mouth

This is an engine designed to mimic the Baldur's Gate 3 dialog system with some improvements that I think would help the flow. The main issues I'm trying to tackle are:

1. In BG3 the character you approach the conversation with is by the one that makes the checks. There's no way to switch who is talking after the fact. This is semi-ok for single player, absolutely horrible for multiplayer. If you ever want to do any of the interesting social combat your main character needs to have at least a 14 in charisma and proficiency in one of the social 3 (persuasion, intimidation, deception). In multiplayer it means that anytime you have a sniff of there being dialog you'd better wrangle that one warlock/bard/paladin/sorcerer to stop looting and come over.
2. In BG3 if another character has a special bit of dialog, say due to being a Dragonborn while talking to a Kobold, you cannot choose that dialog. In singleplayer that's fine, more meat for other playthroughs, but for multiplayer it means that 3 players effectively don't get to do anything for a length of time and that encourages them to go do other stuff without the party which is generally bad.
3. In BG3 single player if you talk to someone that has *been* in the conversation thus far, but has never directly talked to an NPC the NPC treats it as an entirely new dialog session! This still happens in multiplayer but less so for some reason.
4. In BG3 single player there are some incredible moments where Companions and NPCs will communicate with each other inbetween your reply and the next prompt. This is actually impossible in multiplayer.

In both of these issues sometimes in BG3 you can be foreced, just due to how combat ends (see: Nere) to use

In the below example shows a scenario where 4 adventures (Sarah the tiefling fey warlock college of lore bard, James the orc battlemaster fighter, Phika the gloomstalker ranger assassin rogue, and Willup the enchanter wizard) stumble into a tavern late at night.

Example:

> Narrator: As you approach the bar the pudgy tavern keep looks up, clearly happy to see the new guests.

> Gus, the Tavern Keep: "Hello there, welcome to the Lucky Fox! We have one small room open, but it's only got one bed. What can I do for you?"

> `<require skill=Insight dc=14 />`Narrator: Directly above the tavern keeper is a small eye carved into the wood. It's the symbol for the Guild's membership. He is either a part of the guild or a pawn.

    James rolls Wisdom gets 9
    Phika rolls Insight gets 19, apply tag tavern_keeper_known_guild_member
    Sarah rolls Insight gets 1
    Willup rolls Wisdom and gets 15, apply tag tavern_keeper_known_guild_member

1. "Yes, we'd like one room please."
2. "Actually, we're wondering if there's another inn near by? This place seems rather...damp."
3. `<require tag=tavern_keeper_known_guild_member />` "Oh, are you a part of the Guild?"
4. `<require tag=tavern_keeper_known_guild_member />` `<require language=spycode>` `<require location=tavern />` "We'd like to see where the fox sleeps."
4. `<require tag=tavern_keeper_has_special_basement_room />` `<require location=tavern />` ...
5. `<optional skill=deception dc=18 />` "The city guard said we're to have two rooms, so kick out whomever you have to!"

    User selects #1. The character randomly selected is James.

> James: "Yes, we'd like one room please."

> Gus, the Tavern Keep: "Sure, that will be 10 gold."

1. `<require gold=10 />` "That'll take everything we have, but yes we'd like to take the room."
2. `<require gold=10..-1 />` "We can afford that."
3. `<require gold=0..9 />` "We don't have enough for that, so I guess nevermind."
4. `<optional skill=persuasion dc=12>` "It's one room for four people!"
4. `<optional skill=intimidation ability=strength dc=16>` ...
5. `<require language=spycode>` `<require tag=tavern_keeper_known_guild_member />` `<require location=tavern />` "We'd like to see where the fox sleeps."

    User selects #4.
    Design Note: James would have a +0 with no advantage, Phika has a +2 with no advantage, Sarah has a +5 with no advantage, Willup has a +4 with no advantage. The pool is normally Sarah and Willup because they have proficiency in the skill, but Sarah has the highest odds.

> Sarah: It's one room for four people! 10 gold is such a heavy price to pay when one of us will be sleeping on the floor.

    Sarah rolls Persuasion and gets a 21, apply tag "cheaper_rooms".

> Narrator: The tavern keep looks particularly annoyed, but also very tired.

> Gus, the Tavern Keep: "Alright fine I'll go down to 5 gold, but breakfast isn't free and you better clean up your room after!

## Rules

- All Scenes have a series of lines.
- An scene is between one-or-more characters.
- Scenes happen zero-or-more times.
- Lines happen zero-or-more times.
- Replies are by a single character, with the character being picked at random from those that apply and/or have the highest of the skill.
- Scenes with only one reply will simply skip to that reply.
- Lines can have zero or many pre-emptive required conditions.
- Replies may have zero or many required conditions.
- Replies may have zero or many optional conditions.
- Dice Challenges are split into unknown and known, where known challenges can have actions that change the roll.
- If the person who wins the unknown challenge is an NPC then they whisper the information in a follow up (???)
- A reply is either either linked to a subject or a dialog.
- Lines are either done or not done.


## Design

- Characters have one race, many levels. WHAT IF WE TREATED RACE LIKE A 0 LEVEL?!
- Levels have one class.
- Scenes have many lines, has and belongs to many characters, has many events
- Lines have one body.


## Notes

 - attacking
 - bartering
 - journal & journal entry
 - forced dialogs
 - allow character choice in addition to random


## Setup

To start a new project simply open the terminal and type `mix new . --module {{module name}}` replacing `{{module name}}

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `elixir_codespace` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:elixir_codespace, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/elixir_codespace>.
