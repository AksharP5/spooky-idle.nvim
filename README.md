# spooky-idle.nvim

A spooky Neovim plugin that plays eerie sounds and displays ghostly ASCII art when you’ve been idle for too long.  
Perfect for Halloween vibes, or just keeping you on your toes.

---

## Features

- Automatically detects when you’ve been idle.
- Plays random spooky sounds in the background.
- Displays rotating ghostly ASCII art over a dimmed screen.
- Automatically stops when you move or type again.
- Persists your last state between sessions (won’t restart if you stopped it).
- Optionally supports your own custom sound folder.

---

## Requirements

- **Neovim 0.9+**
- **Audio player** (one of):
  - Linux: `paplay`, `ffplay`, or `mpv`
  - macOS: `afplay`, `ffplay`, or `mpv`
  - Windows: `ffplay` or `mpv`

---

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "yourusername/spooky-idle.nvim",
  event = "VeryLazy",
  opts = {
    idle_time = 600000,  -- time before idle triggers (in milliseconds, default = 10 minutes)
    dim_level = 70,      -- darkness level of dim overlay (0–100)
    sound_enabled = true,
    sound_dir = nil,     -- optional custom folder for your own spooky sounds
  },
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "yourusername/spooky-idle.nvim",
  config = function()
    require("spooky-idle.core").setup({
      idle_time = 600000,
      dim_level = 70,
      sound_enabled = true,
      sound_dir = nil,
    })
  end
}
```

---

## Usage

Once installed, spooky-idle will start automatically when you open Neovim  
*(unless you stopped it in a previous session)*.

### Commands

| Command | Description |
|----------|-------------|
| `:SpookyIdleStart` | Start spooky-idle manually |
| `:SpookyIdleStop`  | Stop spooky-idle and save stopped state |
| `:SpookyIdleStatus` | Show whether spooky-idle is active |

---

## Customization

You can add your own spooky sounds by creating a folder with `.mp3`, `.ogg`, `.wav`, etc.  
and pointing to it in your config:

```lua
opts = {
  sound_dir = "~/sounds/spooky"
}
```

Each time spooky-idle triggers, it picks a random sound from that folder.

Default sounds and ASCII ghosts are bundled, so you don’t need to add anything for it to work out of the box.

---

## Persistent State

spooky-idle remembers your last state between sessions:
- If you stopped it last time, it stays stopped when reopening Neovim.
- If it was active, it autostarts next time.

The state file is stored safely under:
```
~/.local/state/nvim/spooky-idle/state.json
```

---

## Known Issues

- Some audio players (like `ffplay`) may leave short pauses before playback.

---

## Why?

Because sometimes you forget you left Neovim open, and you deserve to be haunted for it.

---

## License

MIT License  
Copyright (c) 2025  
