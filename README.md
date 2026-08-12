# Chess Trainer

A chess coach that lives in **one HTML file**. No accounts, no backend, no build
step, no tracking — open it and play. Stockfish is embedded in the page, so it
works offline the moment it finishes downloading, and nothing you do leaves your
own machine.

**Try it:** https://skabone.github.io/chess-trainer/

## What it does

- **Play** — full games against nine opponents, from Pawn (≈350) to Merciless
  (≈2200). Legal moves only, click or tap to move, promotion picker, takebacks,
  back/forward through the game, resign, flip, arrow-key navigation.
- **A coach that explains** — every move you play is analysed and told back to
  you in words: what it cost, what the better idea was, and the line it runs
  into. Not a score — an explanation.
- **Coach mode vs Real game** — coach mode talks as you play and lets you take
  moves back and try again. Real game stays quiet and gives you the whole
  walkthrough at the end.
- **Bots that miss things like people do** — the weaker levels don't just search
  less, they pick a worse-but-real candidate move a set fraction of the time, so
  their mistakes look like mistakes rather than noise.
- **Thirteen piece sets and six board themes** — Staunton, Outline, Duotone,
  Glass, Neo, Relief, Neon, Marble, Minimal, Pixel, Letter, Classic, Etched.
- **A log** — note a bug or an idea while you're playing and it keeps the
  context (the position, the moves, the build). One button turns the batch into
  a brief you can hand to an AI assistant to actually get it fixed.

## Where your data lives

In your browser's `localStorage`, and nowhere else. The page has no server and
makes no network calls at all after it loads — the chess engine is compiled to
WebAssembly and embedded directly in the file. Your log exports to JSON whenever
you want a copy.

## Run it yourself

Download `index.html` and double-click it — that's the whole install. It works
straight off your disk over `file://`; there's nothing to serve.

Or fork this repo and enable GitHub Pages to host your own copy.

## Install it as an app

It runs fine in a browser tab, but you can give it its own window and icon:

- **Desktop (Brave / Chrome / Edge):** open the site, then menu → **Install…**
  (or the install icon in the address bar).
- **iPhone / iPad (Safari):** Share → **Add to Home Screen**.
- **Android (Chrome):** menu → **Add to home screen**.
- **Native macOS app (no Electron, free):** build a real Swift + WKWebView app —
  see [`native/`](native/). `cd native && ./build.sh`, then move
  `Chess Trainer.app` to Applications.

## About this build

The version I use myself is trained on my own 4,380 Chess.com games: it knows my
opening repertoire, the positions I keep losing from, and the blunders I repeat,
and it coaches from that history rather than from an engine's opinion. That
archive is personal, so this public build ships without it — the five tabs that
read from it remove themselves, and Play, the coach, the themes and the log all
work exactly the same.

If you want the same thing for your own games, the builder that produces the
personal version reads a Chess.com archive export and is in the private repo;
open an issue if that's interesting to you.

## Credits

Chess engine: [Stockfish](https://stockfishchess.org/) (GPL-3.0), compiled to
WebAssembly by [nmrugg/stockfish.js](https://github.com/nmrugg/stockfish.js).
Move generation, coaching, pieces and UI are original to this project.

## License

**Free for personal & noncommercial use · created by Mintay Misgano ·
commercial use by permission.**

Licensed under the [PolyForm Noncommercial License 1.0.0](LICENSE).
The bundled Stockfish engine remains under its own GPL-3.0 license.
