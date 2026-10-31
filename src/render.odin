package main

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "game"

print_card_header :: proc() {
	fmt.printfln("%-3s %-20s %-7s %-6s %-6s", "ID", "Name", "Type", "Damage", "Heal")
}

print_card :: proc(c: game.Card) {
	fmt.printfln("%-3d %-20s %-7v %-6d %-6d", c.id, c.name, c.type, c.attack, c.heal)
}

print_deck :: proc(app: App) {
	fmt.printfln("Your Deck (%d/%d):", len(app.deck.cards), game.DECK_MAX)
	print_card_header()
	for id in app.deck.cards {
		if c, ok := game.find_card(app.catalog, id); ok do print_card(c)
	}
}

print_catalog :: proc(app: App) {
	fmt.printfln("%-3s %-20s %-7s %-6s %-6s  %s", "ID", "Name", "Type", "Damage", "Heal", "Description")
	for c in app.catalog.cards {
		fmt.printfln("%-3d %-20s %-7v %-6d %-6d  %s", c.id, c.name, c.type, c.attack, c.heal, c.description)
	}
}

print_fight :: proc(app: App, f: game.Fight) {
	fmt.printfln("Health: %d  Armor: %d", f.player_health, f.player_armor)
	fmt.println()
	fmt.printfln("Level %d  %s  Health: %d", f.monster.level, f.monster.name, f.monster_health)
	if r, ok := f.monster.resistance.?; ok do fmt.printfln("Resists: %v", r)
	print_monster_art(app, f.monster)
	fmt.println()
	fmt.println("Your Hand:")
	fmt.printfln("%-3s %-20s %-7s %-6s %-6s", "#", "Name", "Type", "Damage", "Heal")
	for id, i in f.hand {
		c, _ := game.find_card(app.catalog, id)
		fmt.printfln("%-3d %-20s %-7v %-6d %-6d", i + 1, c.name, c.type, c.attack, c.heal)
	}
	fmt.printfln("Draw Pile: %d cards", len(f.draw_pile))
}

print_monster_art :: proc(app: App, m: game.Monster) {
	path, _ := filepath.join({app.data_dir, "monster-art", m.art_file}, context.temp_allocator)
	art, err := os.read_entire_file(path, context.temp_allocator)
	if err != nil {
		fmt.printfln("(missing art: %s)", path)
		return
	}
	fmt.print(string(art))
}
