-- Content tables are dropped and rebuilt from seed.sql on every start.
-- Only `deck` holds player state and survives between runs (see docs/adr/0001).

DROP TABLE IF EXISTS card;
CREATE TABLE card (
  id          INTEGER PRIMARY KEY,
  name        TEXT    NOT NULL,
  type        TEXT    NOT NULL CHECK (type IN ('Weapon', 'Spell', 'Armor', 'Potion')),
  attack      INTEGER NOT NULL,
  heal        INTEGER NOT NULL,
  description TEXT    NOT NULL
);

DROP TABLE IF EXISTS monster;
CREATE TABLE monster (
  level      INTEGER PRIMARY KEY,
  name       TEXT    NOT NULL,
  health     INTEGER NOT NULL,
  attack     INTEGER NOT NULL,
  resistance TEXT    CHECK (resistance IN ('Weapon', 'Spell', 'Armor', 'Potion')),
  art_file   TEXT    NOT NULL
);

DROP TABLE IF EXISTS default_deck;
CREATE TABLE default_deck (
  position INTEGER PRIMARY KEY,
  card_id  INTEGER NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS deck (
  position INTEGER PRIMARY KEY,
  card_id  INTEGER NOT NULL UNIQUE
);
