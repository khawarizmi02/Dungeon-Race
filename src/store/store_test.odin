package store

import "core:testing"
import "../game"

SCHEMA :: #load("../../data/schema.sql", string)
SEED   :: #load("../../data/seed.sql", string)

@(test)
fresh_store_loads_seed_content :: proc(t: ^testing.T) {
	// Loaded data normally lives for the whole program; let the runner clean it up here.
	context.allocator = context.temp_allocator
	s, ok := open(":memory:", SCHEMA, SEED)
	testing.expect(t, ok, last_error(s))
	defer close(s)

	catalog, catalog_ok := load_catalog(s)
	testing.expect(t, catalog_ok)
	testing.expect_value(t, len(catalog.cards), 50)
	fireball, _ := game.find_card(catalog, 1)
	testing.expect_value(t, fireball.name, "Fireball")
	testing.expect_value(t, fireball.type, game.Card_Type.Spell)

	monsters, monsters_ok := load_monsters(s)
	testing.expect(t, monsters_ok)
	testing.expect_value(t, len(monsters), game.LEVEL_COUNT)
	testing.expect(t, monsters[0].resistance == nil)
	testing.expect(t, monsters[1].resistance == game.Card_Type.Spell)

	deck, deck_ok := load_deck(s)
	testing.expect(t, deck_ok)
	testing.expect_value(t, len(deck.cards), 20)
}

@(test)
saved_deck_round_trips :: proc(t: ^testing.T) {
	// Loaded data normally lives for the whole program; let the runner clean it up here.
	context.allocator = context.temp_allocator
	s, ok := open(":memory:", SCHEMA, SEED)
	testing.expect(t, ok, last_error(s))
	defer close(s)

	deck: game.Deck
	append(&deck.cards, 5, 3, 9)
	testing.expect(t, save_deck(s, deck))

	loaded, _ := load_deck(s)
	testing.expect_value(t, len(loaded.cards), 3)
	testing.expect_value(t, loaded.cards[0], game.Card_Id(5))
	testing.expect_value(t, loaded.cards[2], game.Card_Id(9))
}
