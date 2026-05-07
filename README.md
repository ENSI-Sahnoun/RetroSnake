# RetroSnake 🐍

A retro Snake game written in x86 Assembly for DOS (COM format), designed to run in **DOSBox**.

## Screenshot

> Current screenshot (original):
>
> ![RetroSnake in DOSBox](https://github.com/user-attachments/assets/71a37cc9-a7ac-407c-a7b8-b043c3b390f6)

## Features

- Classic Snake gameplay
- Keyboard controls (arrow keys)
- Score counter
- Collision detection (walls + self)
- Game-over screen with final score

## Controls

- **↑ / ↓ / ← / →**: Move snake
- **Esc**: Quit game

## Files

- `snake_full.asm` → game source (16-bit DOS assembly)

## Prerequisites

- [DOSBox](https://www.dosbox.com/) (recommended: 0.74-3 or newer)
- [NASM](https://www.nasm.us/) (to build the COM executable)

## Build the game

From your project folder on your host machine:

```bash
nasm -f bin snake_full.asm -o SNAKE.COM
```

This creates `SNAKE.COM`.

## Run in DOSBox

1. Open DOSBox.
2. Mount the project folder as drive `C:`.
3. Switch to `C:`.
4. Launch the game executable.

Example session:

```dos
mount c C:\path\to\RetroSnake
c:
SNAKE.COM
```

## Windows quick setup example

```dos
mount c C:\Users\<you>\Downloads\RetroSnake
c:
SNAKE.COM
```

## Linux/macOS quick setup example

```dos
mount c /home/<you>/RetroSnake
c:
SNAKE.COM
```

## Troubleshooting

- **`Illegal command: SNAKE.COM`**
  - Ensure you are in the mounted directory (`c:`) where `SNAKE.COM` exists.
- **Black screen/no movement**
  - Click inside the DOSBox window so it captures keyboard input.
- **`SNAKE.COM` missing**
  - Re-run the NASM build command and confirm file output in the project folder.

---

Enjoy the retro vibes ✨
