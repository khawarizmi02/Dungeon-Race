// Minimal bindings to the system libsqlite3, covering only what Card Dungeon uses.
package sqlite

import "core:c"

foreign import lib "system:sqlite3"

Db :: struct {}
Stmt :: struct {}

OK   :: 0
ROW  :: 100
DONE :: 101

NULL :: 5 // column type

// Tells SQLite to copy bound text before the call returns.
TRANSIENT :: rawptr(~uintptr(0))

@(default_calling_convention = "c", link_prefix = "sqlite3_")
foreign lib {
	open         :: proc(filename: cstring, db: ^^Db) -> c.int ---
	close_v2     :: proc(db: ^Db) -> c.int ---
	errmsg       :: proc(db: ^Db) -> cstring ---
	exec         :: proc(db: ^Db, sql: cstring, callback: rawptr, arg: rawptr, errmsg: ^cstring) -> c.int ---
	free         :: proc(ptr: rawptr) ---
	prepare_v2   :: proc(db: ^Db, sql: cstring, n_byte: c.int, stmt: ^^Stmt, tail: ^cstring) -> c.int ---
	bind_int64   :: proc(stmt: ^Stmt, index: c.int, value: i64) -> c.int ---
	bind_text    :: proc(stmt: ^Stmt, index: c.int, text: cstring, n: c.int, destructor: rawptr) -> c.int ---
	step         :: proc(stmt: ^Stmt) -> c.int ---
	reset        :: proc(stmt: ^Stmt) -> c.int ---
	finalize     :: proc(stmt: ^Stmt) -> c.int ---
	column_type  :: proc(stmt: ^Stmt, col: c.int) -> c.int ---
	column_int64 :: proc(stmt: ^Stmt, col: c.int) -> i64 ---
	column_text  :: proc(stmt: ^Stmt, col: c.int) -> cstring ---
}
