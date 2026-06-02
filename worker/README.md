# FavField Worker (Phase 1)

Yahoo!スポーツナビの [プロ野球](https://baseball.yahoo.co.jp/npb/) ページをスクレイピングし、推し球団の最新試合状況を JSON で返す Cloudflare Workers API です。

## エンドポイント

| Path | 説明 |
|------|------|
| `GET /score?team=T` | 推し球団の最新スコア（略号: G, S, DB, D, T, C, L, F, M, B, H, E） |
| `GET /teams` | 12球団一覧 |
| `GET /health` | ヘルスチェック |

### レスポンス例

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

`status` の値:

- `pre` … 試合前（例: `L - T 18:00`）
- `live` … 試合中（例: `T 1-0 G 7裏`）
- `final` … 試合終了（例: `B 2-3 G`）
- `cancelled` … 試合中止
- `none` … 対象試合なし

## セットアップ

```bash
cd worker
npm install
npm run dev
```

ローカル起動後:

```bash
curl "http://localhost:8787/score?team=T"
curl "http://localhost:8787/teams"
```

## デプロイ

```bash
npm run deploy
```

Cloudflare アカウントにログイン済みである必要があります（`npx wrangler login`）。

## 設計メモ

- Yahoo への直接アクセスは Worker 側のみ。クライアントは JSON を読むだけ。
- Cache API で 45 秒キャッシュ（`wrangler.toml` の `CACHE_TTL_SECONDS` で変更可）。
- 本日の試合を優先し、なければ前日の結果を返す。
- 試合中は `/npb/game/{id}/score` からイニング情報を補完。

## 注意

- Yahoo の HTML 構造変更で壊れる可能性があります。修正は Worker 側のみで対応可能です。
- スクレイピングのため、過度なリクエストは避けてください（キャッシュ必須）。
