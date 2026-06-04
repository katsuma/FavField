# FavField

An Apple Watch app that shows live NPB scores for your favorite team.

## Structure

- [`worker/`](worker/) — Cloudflare Workers API (Phase 1)
- [`FavFieldWatch/`](FavFieldWatch/) — watchOS app (Phase 2)
- [`FavFieldWidget/`](FavFieldWidget/) — WidgetKit complication (Phase 3)
- [`Shared/`](Shared/) — API client and preferences shared by app + widget

## Requirements

- Xcode 26+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- Apple Developer Program account (for App Groups and device install)
- Cloudflare account (for Worker deploy)

## Worker (API)

Deploy the score API:

```bash
cd worker
npm install
npx wrangler login   # first time only
npm run deploy
```

Endpoints:

- Base URL: `https://fav-field.katsuma.workers.dev`
- [`/teams`](https://fav-field.katsuma.workers.dev/teams) — 12 NPB teams
- `/score?team=T` — latest one-line score (e.g. `T 1-0 G 7裏`)

Update `Shared/Constants/AppConstants.swift` if you use a different Worker URL.

Local dev:

```bash
cd worker && npm run dev
curl "http://localhost:8787/score?team=T"
```

## Build (watchOS)

```bash
make build
```

This runs `xcodegen generate` and builds for the watchOS simulator SDK.

Open in Xcode:

```bash
xcodegen generate
open FavField.xcodeproj
```

## Xcode setup

### Signing

1. Select target **FavFieldWatch** → **Signing & Capabilities**
2. Set **Team** to your Developer Program team
3. Enable **App Groups** → check `group.tv.katsuma.FavField`
4. Repeat for **FavFieldWidget**

Register on [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list) if needed:

- App Group: `group.tv.katsuma.FavField`
- App IDs: `tv.katsuma.FavField.watchkitapp`, `tv.katsuma.FavField.watchkitapp.widget` (with App Groups enabled)

### Info.plist

The watch app requires `WKApplication` and `WKWatchOnly` in `FavFieldWatch/Resources/Info.plist` (already configured via `project.yml`).

## Simulator

1. Scheme: **FavFieldWatch**
2. Destination: an **Apple Watch** simulator (paired with an iPhone simulator)
3. **Product → Run** (⌘R)
4. Pick a favorite team in the app

### Add complication (simulator)

1. On the Watch simulator, long-press the watch face → **Edit**
2. Tap a complication slot → choose **FavField Score**
3. Confirm the one-line score appears (e.g. `E - T 18:00`)

Changing the team in the app reloads the widget timeline automatically.

## Device install

1. Pair your Apple Watch with your iPhone
2. Connect the iPhone to your Mac
3. In Xcode, select your **Apple Watch** as the run destination
4. **Product → Run** (⌘R)

If install fails, check **Signing & Capabilities** on both targets and that App Groups match on the Developer Portal.

### Add complication (device)

1. Long-press the watch face → **Edit**
2. Add **FavField Score** to an inline or rectangular slot

## Usage

1. Open FavField on Apple Watch and pick your favorite team (one of 12 NPB teams).
2. The main screen shows the latest score line from the Worker API.
3. Tap **Refresh** to fetch the latest score.
4. Add the **FavField Score** complication for always-visible score on your watch face.

## Notes

- App Group `group.tv.katsuma.FavField` shares the selected team between the app and widget.
- Complication refresh uses status-based intervals: ~3 min (live), ~15 min (scheduled), ~30 min (final). watchOS may delay updates further due to system budget limits.
- Scores are scraped from [Yahoo! Sports NPB](https://baseball.yahoo.co.jp/npb/); HTML changes may require Worker updates only.
