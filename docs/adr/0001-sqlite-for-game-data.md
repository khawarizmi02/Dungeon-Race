# SQLite for game data, with content rebuilt from seed on every start

The Odin rewrite stores the Card Catalog, the Monsters and the player's saved Deck in a local SQLite database (`card_dungeon.db`, next to the executable, gitignored). Odin ships no SQLite bindings, so we keep a small hand-written binding package (`src/sqlite/`) that links the system `libsqlite3` and covers only the calls we use.

Game content lives in git as `data/schema.sql` + `data/seed.sql`. On every start the game drops and recreates the Card Catalog and Monster tables from those files; only the `deck` table survives between runs, and Deck entries pointing at Cards that no longer exist are dropped. Monster ASCII art stays as plain files in `data/monster-art/`, referenced by file name.

## Considered options

- **Keep the original whitespace-separated `.txt` files.** Simplest, but needed hand-rolled parsing, tricks like hyphens standing in for spaces, and ad-hoc save logic for the Deck.
- **Commit the `.db` file itself.** Binary, so content changes can't be reviewed in diffs.
- **Third-party Odin SQLite bindings.** Adds an outside dependency for about ten functions.

## Consequences

- Editing `seed.sql` takes effect on the next launch, with no migrations needed for content. The cost is that content tables must never hold player state.
- The build needs `libsqlite3` installed on the machine.
