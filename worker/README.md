# FavField Worker (Phase 1)

A Cloudflare Workers API that scrapes [NPB scores on Yahoo! Sports](https://baseball.yahoo.co.jp/npb/) and returns the latest game status for a favorite team as JSON.

## Endpoints

| Path | Description |
|------|-------------|
| `GET /score?team=T` | Latest score for a team (abbr: G, S, DB, D, T, C, L, F, M, B, H, E) |
| `GET /teams` | List of all 12 NPB teams |
| `GET /health` | Health check |

### Example response

```json
{
  "status": "live",
  "away": { "abbr": "T", "name": "阪神", "score": 1 },
  "home": { "abbr": "G", "name": "巨人", "score": 0 },
  "inning": 7,
  "half": "裏",
  "startTime": null,
  "display": "T 1-0 G 7裏",
  "gameId": "2021038951",
  "updatedAt": "2026-06-03T00:00:00.000Z"
}
```

`status` values:

- `pre` — Before first pitch (e.g. `L - T 18:00`)
- `live` — In progress (e.g. `T 1-0 G 7裏`)
- `final` — Game over (e.g. `B 2-3 G`)
- `cancelled` — Postponed or cancelled
- `none` — No matching game found

## Setup

```bash
cd worker
npm install
npm run dev
```

After the dev server starts:

```bash
curl "http://localhost:8787/score?team=T"
curl "http://localhost:8787/teams"
```

## Deploy

```bash
npm run deploy
```

Requires a logged-in Cloudflare account (`npx wrangler login`).

## Design notes

- Only the Worker talks to Yahoo directly; clients consume JSON.
- Responses are cached for 45 seconds via the Cache API (configurable via `CACHE_TTL_SECONDS` in `wrangler.toml`).
- Today's game is preferred; if none exists, yesterday's result is returned.
- Inning details during live games are enriched from `/npb/game/{id}/score`.

## Caveats

- Scraping may break if Yahoo changes its HTML. Fixes can be deployed on the Worker side only.
- Avoid excessive requests to Yahoo; caching is required.
