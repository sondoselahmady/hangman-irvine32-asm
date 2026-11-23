# Hangman (x86 Assembly / Irvine32)

Console Hangman game written in x86 assembly using the Irvine32 library. Picks a random word from three categories (`Social Media`, `Engineering Majors`, and `Digital Design`), tracks wrong guesses and remaining lives, and draws the ASCII gallows as you play.

## What's Inside
- `Hangman.asm` — Word tables, `MasterTable` pointer/length lookup, game loop, lowercase-to-uppercase conversion, ASCII gallows drawing, and win/loss checks.

## How to Run
1. Open `Hangman.asm` in a Visual Studio project set up with MASM and the Irvine32 library (or assemble via command line with `ml /coff Hangman.asm /link /subsystem:console Irvine32.lib Kernel32.lib User32.lib`).
2. Run the compiled console executable.
