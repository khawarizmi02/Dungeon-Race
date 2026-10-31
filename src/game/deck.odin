package game

import "core:slice"

DECK_MIN :: 5
DECK_MAX :: 20

// The player's saved selection of distinct Cards from the Card Catalog.
Deck :: struct {
	cards: [dynamic]Card_Id,
}

Deck_Error :: enum {
	None,
	Unknown_Card,
	Already_In_Deck,
	Deck_Full,
	Not_In_Deck,
}

deck_add :: proc(deck: ^Deck, catalog: Card_Catalog, id: Card_Id) -> Deck_Error {
	if _, ok := find_card(catalog, id); !ok do return .Unknown_Card
	if slice.contains(deck.cards[:], id) do return .Already_In_Deck
	if len(deck.cards) >= DECK_MAX do return .Deck_Full
	append(&deck.cards, id)
	return .None
}

deck_remove :: proc(deck: ^Deck, id: Card_Id) -> Deck_Error {
	i, found := slice.linear_search(deck.cards[:], id)
	if !found do return .Not_In_Deck
	ordered_remove(&deck.cards, i)
	return .None
}

deck_clear :: proc(deck: ^Deck) {
	clear(&deck.cards)
}

// A Run cannot start with fewer than DECK_MIN Cards.
deck_can_start_run :: proc(deck: Deck) -> bool {
	return len(deck.cards) >= DECK_MIN
}
