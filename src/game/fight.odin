package game

import "core:math/rand"

HAND_SIZE          :: 5
PLAYER_MAX_HEALTH  :: 20
LEVEL_COUNT        :: 5
RESISTED_DAMAGE    :: 0.8 // fraction of damage a Monster takes from its Resistance

Monster :: struct {
	level:      int,
	name:       string,
	health:     int,
	attack:     int,
	resistance: Maybe(Card_Type),
	art_file:   string,
}

Fight_Outcome :: enum {
	Ongoing,
	Won,
	Lost,
}

// One battle against one Monster.
Fight :: struct {
	monster:        Monster,
	monster_health: int,
	player_health:  int,
	player_armor:   int,
	draw_pile:      [dynamic]Card_Id,
	hand:           [dynamic]Card_Id,
}

// Resets the player, shuffles the Deck into a Draw Pile and draws the opening Hand.
fight_init :: proc(deck: Deck, monster: Monster) -> Fight {
	f := Fight {
		monster        = monster,
		monster_health = monster.health,
		player_health  = PLAYER_MAX_HEALTH,
	}
	append(&f.draw_pile, ..deck.cards[:])
	rand.shuffle(f.draw_pile[:])
	for _ in 0 ..< HAND_SIZE do draw_card(&f)
	return f
}

fight_destroy :: proc(f: ^Fight) {
	delete(f.draw_pile)
	delete(f.hand)
}

draw_card :: proc(f: ^Fight) -> bool {
	if len(f.draw_pile) == 0 do return false
	append(&f.hand, pop(&f.draw_pile))
	return true
}

// Player Turn: play the Card at `hand_index`, then draw a replacement if any remain.
play_card :: proc(f: ^Fight, catalog: Card_Catalog, hand_index: int) {
	card, _ := find_card(catalog, f.hand[hand_index])
	ordered_remove(&f.hand, hand_index)
	apply_card(f, card)
	draw_card(f)
}

// TODO(rules): Weapon/Spell damage the Monster (RESISTED_DAMAGE against its Resistance),
// Armor adds armor, Potion heals.
apply_card :: proc(f: ^Fight, card: Card) {
}

// TODO(rules): Monster attacks; armor absorbs damage before health does.
monster_turn :: proc(f: ^Fight) {
}

fight_outcome :: proc(f: Fight) -> Fight_Outcome {
	if f.player_health <= 0 do return .Lost
	if f.monster_health <= 0 do return .Won
	if len(f.hand) == 0 do return .Lost
	return .Ongoing
}
