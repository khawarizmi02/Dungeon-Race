// All database access. Returns `game` types; callers never see SQL.
package store

import "core:strings"
import "../game"
import sql "../sqlite"

Store :: struct {
	db: ^sql.Db,
}

// Opens (or creates) the database, rebuilds the content tables from `schema` + `seed`,
// gives a brand-new database the default Deck, and drops Deck entries for Cards that no longer exist.
open :: proc(path: string, schema, seed: string) -> (s: Store, ok: bool) {
	if sql.open(strings.clone_to_cstring(path, context.temp_allocator), &s.db) != sql.OK do return s, false

	is_new := user_version(s) == 0
	exec(s, "BEGIN") or_return
	exec(s, schema) or_return
	exec(s, seed) or_return
	if is_new {
		exec(s, "INSERT INTO deck (position, card_id) SELECT position, card_id FROM default_deck") or_return
		exec(s, "PRAGMA user_version = 1") or_return
	}
	exec(s, "DELETE FROM deck WHERE card_id NOT IN (SELECT id FROM card)") or_return
	exec(s, "COMMIT") or_return
	return s, true
}

close :: proc(s: Store) {
	sql.close_v2(s.db)
}

last_error :: proc(s: Store) -> string {
	return string(sql.errmsg(s.db))
}

load_catalog :: proc(s: Store) -> (catalog: game.Card_Catalog, ok: bool) {
	stmt := prepare(s, "SELECT id, name, type, attack, heal, description FROM card ORDER BY id") or_return
	defer sql.finalize(stmt)

	cards: [dynamic]game.Card
	for sql.step(stmt) == sql.ROW {
		type := game.card_type_from_string(column_string(stmt, 2)) or_return
		append(&cards, game.Card {
			id          = game.Card_Id(sql.column_int64(stmt, 0)),
			name        = strings.clone(column_string(stmt, 1)),
			type        = type,
			attack      = int(sql.column_int64(stmt, 3)),
			heal        = int(sql.column_int64(stmt, 4)),
			description = strings.clone(column_string(stmt, 5)),
		})
	}
	return {cards = cards[:]}, true
}

load_monsters :: proc(s: Store) -> (monsters: []game.Monster, ok: bool) {
	stmt := prepare(s, "SELECT level, name, health, attack, resistance, art_file FROM monster ORDER BY level") or_return
	defer sql.finalize(stmt)

	list: [dynamic]game.Monster
	for sql.step(stmt) == sql.ROW {
		m := game.Monster {
			level    = int(sql.column_int64(stmt, 0)),
			name     = strings.clone(column_string(stmt, 1)),
			health   = int(sql.column_int64(stmt, 2)),
			attack   = int(sql.column_int64(stmt, 3)),
			art_file = strings.clone(column_string(stmt, 5)),
		}
		if sql.column_type(stmt, 4) != sql.NULL {
			m.resistance = game.card_type_from_string(column_string(stmt, 4)) or_return
		}
		append(&list, m)
	}
	return list[:], true
}

load_deck :: proc(s: Store) -> (deck: game.Deck, ok: bool) {
	stmt := prepare(s, "SELECT card_id FROM deck ORDER BY position") or_return
	defer sql.finalize(stmt)

	for sql.step(stmt) == sql.ROW {
		append(&deck.cards, game.Card_Id(sql.column_int64(stmt, 0)))
	}
	return deck, true
}

save_deck :: proc(s: Store, deck: game.Deck) -> bool {
	exec(s, "BEGIN") or_return
	exec(s, "DELETE FROM deck") or_return

	stmt, ok := prepare(s, "INSERT INTO deck (position, card_id) VALUES (?, ?)")
	if !ok do return false
	defer sql.finalize(stmt)

	for id, i in deck.cards {
		sql.bind_int64(stmt, 1, i64(i + 1))
		sql.bind_int64(stmt, 2, i64(id))
		if sql.step(stmt) != sql.DONE {
			exec(s, "ROLLBACK")
			return false
		}
		sql.reset(stmt)
	}
	return exec(s, "COMMIT")
}

@(private)
exec :: proc(s: Store, query: string) -> bool {
	return sql.exec(s.db, strings.clone_to_cstring(query, context.temp_allocator), nil, nil, nil) == sql.OK
}

@(private)
prepare :: proc(s: Store, query: string) -> (stmt: ^sql.Stmt, ok: bool) {
	rc := sql.prepare_v2(s.db, strings.clone_to_cstring(query, context.temp_allocator), -1, &stmt, nil)
	return stmt, rc == sql.OK
}

@(private)
user_version :: proc(s: Store) -> int {
	stmt, ok := prepare(s, "PRAGMA user_version")
	if !ok do return 0
	defer sql.finalize(stmt)
	if sql.step(stmt) != sql.ROW do return 0
	return int(sql.column_int64(stmt, 0))
}

// The returned string is only valid until the next step/finalize on `stmt`.
@(private)
column_string :: proc(stmt: ^sql.Stmt, col: i32) -> string {
	return string(sql.column_text(stmt, col))
}
