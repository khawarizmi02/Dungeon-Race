# Card Dungeon Glossary

Card Dungeon is a single-player card game: the player builds a Deck, then fights a series of Monsters by playing cards from their Hand.

## Cards

**Card**:
A single playable item with a name, a Card Type, an attack value, a heal value and a description.
_Avoid_: item, ability

**Card Type**:
The category of a Card, which decides what playing it does: Weapon, Spell, Armor or Potion.
_Avoid_: ability type, skill

**Card Catalog**:
Every Card that exists in the game. The player picks from it when building their Deck.
_Avoid_: card list, all cards, deck

**Deck**:
The player's saved selection of 5 to 20 distinct Cards from the Card Catalog, kept between sessions. A Run cannot start with fewer than 5 Cards.
_Avoid_: player deck, deck list

## Fighting

**Run**:
The sequence of Fights from Level 1 up to Level 5. It ends when the player loses a Fight, quits between Fights, or beats Level 5.
_Avoid_: game, session

**Fight**:
One battle against one Monster, alternating Player Turns and Monster Turns until either side reaches zero health. The player's health and armor are fully reset at the start of every Fight.
_Avoid_: game, battle

**Player Turn**:
The part of a Fight where the player plays one Card from their Hand, then draws one from the Draw Pile if any remain.

**Monster Turn**:
The part of a Fight where the Monster attacks the player. Armor absorbs the damage before health does.

**Draw Pile**:
A shuffled copy of the Deck used during one Fight. Cards are drawn from it into the Hand. Once it is empty the player keeps playing from the Hand, and a player with no Cards left loses the Fight.
_Avoid_: current deck, deck

**Hand**:
The up to 5 Cards the player can play on their current turn.
_Avoid_: hand list

**Monster**:
The opponent in a Fight, with health, attack and a Resistance.

**Resistance**:
The one Card Type a Monster takes reduced damage from.
_Avoid_: skill, monster type

**Level**:
A Monster's position in the run, from 1 to 5. Higher Levels are stronger.
