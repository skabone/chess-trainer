# Chess Trainer — native macOS app

A genuinely native macOS app: a tiny Swift + WKWebView wrapper. No Electron, no
Chromium, no dependencies to download, nothing to pay for — it uses the WebKit
engine already in macOS and the Swift compiler from Xcode Command Line Tools.

## Build it

```bash
cd native
./build.sh
mv ChessTrainer.app /Applications/
```

Then open it from Launchpad or Spotlight like any other app.

## How it differs from the Daybook wrapper

Daybook's app loads the hosted site, so it stays current and cloud sync works.
This one **bundles `index.html` inside the app** instead. The chess engine is
compiled into the page, the app makes no network calls, and it should keep
working on a plane or with the wifi off. The trade is that a new version means
rebuilding: pull, then `./build.sh` again.

Your data (log entries, theme, piece set) lives in the app's own private
WebKit storage, separate from any browser.
