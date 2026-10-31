package game

import "core:testing"

@(private = "file")
test_catalog :: proc() -> Card_Catalog {
	@(static) cards := [?]Card {
		{id = 1, name = "Sword", type = .Weapon, attack = 10},
		{id = 2, name = "Shield", type = .Armor, heal = 5},
		{id = 3, name = "Fireball", type = .Spell, attack = 5},
		{id = 4, name = "Healing Potion", type = .Potion, heal = 10},
		{id = 5, name = "Bow", type = .Weapon, attack = 8},
		{id = 6, name = "Hammer", type = .Weapon, attack = 15},
	}
	return {cards = cards[:]}
}

@(test)
deck_rejects_unknown_and_duplicate_cards :: proc(t: ^testing.T) {
	catalog := test_catalog()
	deck: Deck
	defer delete(deck.cards)

	testing.expect_value(t, deck_add(&deck, catalog, 1), Deck_Error.None)
	testing.expect_value(t, deck_add(&deck, catalog, 1), Deck_Error.Already_In_Deck)
	testing.expect_value(t, deck_add(&deck, catalog, 99), Deck_Error.Unknown_Card)
	testing.expect_value(t, len(deck.cards), 1)
}

@(test)
deck_is_capped_at_max :: proc(t: ^testing.T) {
	cards: [DECK_MAX + 1]Card
	for &c, i in cards do c.id = Card_Id(i + 1)
	catalog := Card_Catalog{cards[:]}
	deck: Deck
	defer delete(deck.cards)

	for i in 1 ..= DECK_MAX do testing.expect_value(t, deck_add(&deck, catalog, Card_Id(i)), Deck_Error.None)
	testing.expect_value(t, deck_add(&deck, catalog, DECK_MAX + 1), Deck_Error.Deck_Full)
}

@(test)
deck_needs_minimum_to_start_run :: proc(t: ^testing.T) {
	catalog := test_catalog()
	deck: Deck
	defer delete(deck.cards)

	for i in 1 ..< DECK_MIN do deck_add(&deck, catalog, Card_Id(i))
	testing.expect(t, !deck_can_start_run(deck))
	deck_add(&deck, catalog, DECK_MIN)
	testing.expect(t, deck_can_start_run(deck))

	testing.expect_value(t, deck_remove(&deck, 1), Deck_Error.None)
	testing.expect_value(t, deck_remove(&deck, 1), Deck_Error.Not_In_Deck)
}

@(test)
fight_draws_opening_hand :: proc(t: ^testing.T) {
	catalog := test_catalog()
	deck: Deck
	defer delete(deck.cards)
	for c in catalog.cards do deck_add(&deck, catalog, c.id)

	f := fight_init(deck, Monster{health = 10})
	defer fight_destroy(&f)

	testing.expect_value(t, len(f.hand), HAND_SIZE)
	testing.expect_value(t, len(f.draw_pile), len(catalog.cards) - HAND_SIZE)
	testing.expect_value(t, f.player_health, PLAYER_MAX_HEALTH)
}

@(test)
fight_is_lost_when_no_cards_left :: proc(t: ^testing.T) {
	catalog := test_catalog()
	deck: Deck
	defer delete(deck.cards)
	for c in catalog.cards do deck_add(&deck, catalog, c.id)

	f := fight_init(deck, Monster{health = 1000})
	defer fight_destroy(&f)

	for fight_outcome(f) == .Ongoing do play_card(&f, catalog, 0)
	testing.expect_value(t, fight_outcome(f), Fight_Outcome.Lost)
	testing.expect_value(t, len(f.hand), 0)
}
