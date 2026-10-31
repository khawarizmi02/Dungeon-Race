package main

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "game"
import "store"

App :: struct {
	data_dir: string,
	db:       store.Store,
	catalog:  game.Card_Catalog,
	monsters: []game.Monster,
	deck:     game.Deck,
}

main :: proc() {
	app, ok := app_init()
	if !ok do os.exit(1)
	defer store.close(app.db)

	terminal_init()
	main_menu(&app)
}

app_init :: proc() -> (app: App, ok: bool) {
	exe_dir, err := os.get_executable_directory(context.allocator)
	if err != nil {
		fmt.eprintln("Cannot find the program's directory:", err)
		return app, false
	}
	app.data_dir, _ = filepath.join({exe_dir, "data"})

	schema := read_data_file(app, "schema.sql") or_return
	seed := read_data_file(app, "seed.sql") or_return
	db_path, _ := filepath.join({exe_dir, "card_dungeon.db"})

	if app.db, ok = store.open(db_path, schema, seed); !ok {
		fmt.eprintln("Cannot open database:", store.last_error(app.db))
		return app, false
	}
	app.catalog = store.load_catalog(app.db) or_return
	app.monsters = store.load_monsters(app.db) or_return
	app.deck = store.load_deck(app.db) or_return
	return app, true
}

read_data_file :: proc(app: App, name: string) -> (contents: string, ok: bool) {
	path, _ := filepath.join({app.data_dir, name}, context.temp_allocator)
	data, err := os.read_entire_file(path, context.allocator)
	if err != nil {
		fmt.eprintln("Cannot read", path, "-", err)
		return "", false
	}
	return string(data), true
}

main_menu :: proc(app: ^App) {
	for {
		free_all(context.temp_allocator)
		clear_screen()
		fmt.println("Card Dungeon")
		fmt.println("1. Start Run")
		fmt.println("2. My Deck")
		fmt.println("3. Exit")
		pick := read_int("Enter your choice: ")
		switch pick {
		case 1: start_run(app)
		case 2: deck_menu(app)
		case 3: return
		}
	}
}

deck_menu :: proc(app: ^App) {
	for {
		clear_screen()
		print_deck(app^)
		fmt.println()
		fmt.println("1. Edit Deck")
		fmt.println("2. Clear Deck")
		fmt.println("3. Show Card Catalog")
		fmt.println("4. Back")
		pick := read_int("Enter your choice: ")
		switch pick {
		case 1:
			edit_menu(app)
		case 2:
			game.deck_clear(&app.deck)
			save_deck(app^)
		case 3:
			clear_screen()
			print_catalog(app^)
			pause()
		case 4:
			return
		}
	}
}

edit_menu :: proc(app: ^App) {
	for {
		clear_screen()
		print_deck(app^)
		fmt.println()
		fmt.println("1. Remove Card")
		fmt.println("2. Add Card")
		fmt.println("3. Done")
		pick := read_int("Your choice: ")
		err: game.Deck_Error
		switch pick {
		case 1:
			id := read_int("Enter card id to remove: ")
			err = game.deck_remove(&app.deck, game.Card_Id(id))
		case 2:
			id := read_int("Enter card id to add: ")
			err = game.deck_add(&app.deck, app.catalog, game.Card_Id(id))
		case 3:
			return
		case:
			continue
		}
		if err != .None {
			fmt.println(deck_error_message(err))
			pause()
			continue
		}
		save_deck(app^)
	}
}

deck_error_message :: proc(err: game.Deck_Error) -> string {
	switch err {
	case .None:            return ""
	case .Unknown_Card:    return "There is no card with that id."
	case .Already_In_Deck: return "That card is already in your Deck."
	case .Deck_Full:       return "Your Deck is full. Remove a card first."
	case .Not_In_Deck:     return "That card is not in your Deck."
	}
	return ""
}

save_deck :: proc(app: App) {
	if !store.save_deck(app.db, app.deck) {
		fmt.eprintln("Could not save your Deck:", store.last_error(app.db))
		pause()
	}
}

start_run :: proc(app: ^App) {
	if !game.deck_can_start_run(app.deck) {
		fmt.printfln("Your Deck needs at least %d cards to start a Run.", game.DECK_MIN)
		pause()
		return
	}
	for monster in app.monsters {
		outcome := run_fight(app^, monster)
		clear_screen()
		if outcome != .Won {
			fmt.println("YOU LOSE")
			pause()
			return
		}
		fmt.println("YOU WIN")
		if monster.level == len(app.monsters) {
			fmt.println("You have defeated every Monster. Thank you for playing!")
			pause()
			return
		}
		answer := read_line("Continue to the next Level? (y/n): ")
		if answer == "n" do return
	}
}

run_fight :: proc(app: App, monster: game.Monster) -> game.Fight_Outcome {
	f := game.fight_init(app.deck, monster)
	defer game.fight_destroy(&f)

	for {
		// Player Turn
		clear_screen()
		print_fight(app, f)
		pick := read_int("Pick a card to play: ")
		if pick < 1 || pick > len(f.hand) do continue
		game.play_card(&f, app.catalog, pick - 1)
		if outcome := game.fight_outcome(f); outcome != .Ongoing do return outcome

		// Monster Turn
		game.monster_turn(&f)
		fmt.printfln("%s attacks!", monster.name)
		pause()
		if outcome := game.fight_outcome(f); outcome != .Ongoing do return outcome
	}
}
