// Pure game types and rules. No printing, no files, no database.
package game

import "core:reflect"

Card_Type :: enum {
	Weapon,
	Spell,
	Armor,
	Potion,
}

Card_Id :: distinct int

Card :: struct {
	id:          Card_Id,
	name:        string,
	type:        Card_Type,
	attack:      int,
	heal:        int,
	description: string,
}

// Every Card that exists, ordered by id.
Card_Catalog :: struct {
	cards: []Card,
}

find_card :: proc(catalog: Card_Catalog, id: Card_Id) -> (card: Card, ok: bool) {
	for c in catalog.cards {
		if c.id == id do return c, true
	}
	return {}, false
}

card_type_from_string :: proc(s: string) -> (Card_Type, bool) {
	return reflect.enum_from_name(Card_Type, s)
}
