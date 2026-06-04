# FavField

An Apple Watch app that shows live NPB scores for your favorite team.

## Structure

- [`worker/`](worker/) — Cloudflare Workers API (Phase 1)
- [`FavFieldWatch/`](FavFieldWatch/) — watchOS app (Phase 2)
- [`FavFieldWidget/`](FavFieldWidget/) — WidgetKit complication
- [`Shared/`](Shared/) — API client and preferences shared by app + widget

## Requirements

- Xcode 26+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Build

```bash
make build
```

This runs `xcodegen generate` and builds the watchOS app for the simulator SDK.

## API

The watch app reads scores from the deployed Worker:

- Base URL: `https://fav-field.katsuma.workers.dev`
- Teams: [`/teams`](https://fav-field.katsuma.workers.dev/teams)
- Score: `/score?team=T`

## Usage

1. Open the app on Apple Watch and pick your favorite team.
2. The main screen shows the latest one-line score (for example `T 1-0 G 7裏`).
3. Add the FavField complication to your watch face for inline score display.

## Notes

- App Group `group.tv.katsuma.FavField` shares the selected team between the app and widget.
- Complication refresh follows watchOS budget limits (roughly every few minutes during live games).
- Device install requires an Apple Developer account and code signing setup in Xcode.
