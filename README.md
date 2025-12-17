## dockedit

`dockedit` is a command‑line tool for editing the macOS Dock. It lets you add, remove, move, and manage apps and folders (including inserting spacer tiles) without touching System Settings.

### Installation

- **From RubyGems**:

```bash
gem install dockedit
```

- **From source (local clone)**:

```bash
bundle install
bundle exec rake rspec
```

This installs the `dockedit` executable.

### Basic usage

```bash
dockedit <subcommand> [options] [args]
```

Global behavior:

- **`dockedit --help`**: Show top‑level help and subcommand list.
- **`dockedit help <subcommand>`**: Show detailed help for a subcommand (`add`, `move`, `remove`, `space`).
- **`dockedit -v` / `dockedit --version`**: Print the current version.

Subcommands:

- `add`   – add apps and/or folders to the Dock.
- `remove` – remove apps and/or folders from the Dock.
- `move` – move an existing Dock item after another item.
- `space` – insert one or more spacer tiles in the apps section.

Folder shortcuts you can use instead of full paths:

- `desktop`, `downloads`, `home`/`~`, `library`, `documents`, `applications`/`apps`, `sites`.

---

## Subcommands

### `add` – add apps and folders

**Usage**:

```bash
dockedit add [options] <app_or_folder> [...]
```

You can pass any mix of:

- App names (e.g. `Safari`, `Terminal`, `Notes`) – resolved via Spotlight-style search.
- Explicit app paths (e.g. `/Applications/Safari.app`).
- Folder paths (e.g. `~/Downloads`, `~/Sites`), including the folder shortcuts above.

If a folder already exists in the Dock, `dockedit add` will update its view/style if you pass `--show` or `--display` rather than adding a duplicate.

**Options**:

- **`-a`, `--after ITEM`**
  Insert the new item(s) after the specified Dock item (app or folder).
  `ITEM` is matched fuzzily by name (e.g. `Safari`, `Terminal`, or a folder name).

- **`--show TYPE`, `--view TYPE`** (folders only)
  Set the folder view mode. `TYPE` accepts:
  - `fan` / `f`
  - `grid` / `g`
  - `list` / `l`
  - `auto` / `a` (default)

- **`--display TYPE`** (folders only)
  Set the folder style/appearance. `TYPE` accepts:
  - `folder` / `f` – shows the folder icon
  - `stack` / `s` – shows a stack of contents

**Examples**:

```bash
# Add apps to the end of the apps section
dockedit add Safari Terminal

# Add Downloads folder as a grid-style stack
dockedit add ~/Downloads --show grid --display stack

# Add Notes after Safari
dockedit add --after Safari Notes

# Add Sites folder with folder icon and grid view
dockedit add ~/Sites --display folder --show grid
```

---

### `remove` – remove apps and folders

**Usage**:

```bash
dockedit remove <app_or_folder> [...]
```

You can pass:

- App names or bundle identifiers (e.g. `Safari`, `com.apple.Safari`).
- Folder paths or folder names (including the defined shortcuts).

If an item can’t be found, `dockedit` prints a warning and continues with the remaining items.

**Examples**:

```bash
# Remove multiple apps
dockedit remove Safari Terminal

# Remove Downloads folder
dockedit remove ~/Downloads
```

To see help for this subcommand:

```bash
dockedit help remove
```

---

### `move` – move a Dock item after another

**Usage**:

```bash
dockedit move --after <target> <item_to_move>
# or
dockedit move <item_to_move> --after <target>
```

`move` lets you reorder existing Dock items relative to another item. Both items must already be in the Dock, and they must be in the same section (apps or folders) — moving between sections is not allowed.

**Options**:

- **`-a`, `--after ITEM`** (required)
  The target item after which `item_to_move` should be placed. Fuzzy‑matched by name.

**Rules and behavior**:

- If either the target or the item to move is not found, `dockedit` exits with an error.
- You cannot move an item after itself.
- You cannot move items between the apps section and the folders section.

**Examples**:

```bash
# Explicit: move Safari after Terminal
dockedit move --after Terminal Safari

# Alternative order: same effect
dockedit move Safari --after Terminal
```

To see help for this subcommand:

```bash
dockedit help move
```

---

### `space` – insert spacer tiles

**Usage**:

```bash
dockedit space [options]
```

`space` inserts one or more spacer tiles in the apps section of the Dock. You can add a space at the end of the apps list, or after specific apps.

**Options**:

- **`-s`, `--small`, `--half`**
  Insert a small/half-size space instead of a full-size spacer.

- **`-a`, `--after APP`** (repeatable)
  Insert a space after the specified app. You can use this option multiple times to insert several spaces in different locations in one command. Each `APP` is fuzzy‑matched by name.

**Behavior**:

- With no `--after` options, a single space (small or full) is added at the end of the apps section.
- With one or more `--after` options, a space is inserted after each referenced app, one by one.
- If an `APP` is not found, `dockedit` exits with an error.

**Examples**:

```bash
# Add a full-size space at the end of the apps section
dockedit space

# Add a single small space at the end
dockedit space --small

# Add a full-size space after Safari
dockedit space --after Safari

# Add small spaces after Terminal and Safari (in that order)
dockedit space --small --after Terminal --after Safari
```

To see help for this subcommand:

```bash
dockedit help space
```

---

### Global help and version

**Top-level help**:

```bash
dockedit --help
dockedit help
```

Shows the main usage, subcommand list, folder shortcuts, and examples.

**Subcommand help**:

```bash
dockedit help add
dockedit help move
dockedit help remove
dockedit help space
```

**Version**:

```bash
dockedit -v
dockedit --version
```

Prints the current `dockedit` version (from `DockEdit::VERSION`).


