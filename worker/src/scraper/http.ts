const BASE_URL = "https://baseball.yahoo.co.jp";
const USER_AGENT =
  "FavField/0.1; NPB score fetcher";

export async function fetchHtml(path: string): Promise<string> {
  const url = path.startsWith("http") ? path : `${BASE_URL}${path}`;
  const response = await fetch(url, {
    headers: {
      "User-Agent": USER_AGENT,
      Accept: "text/html,application/xhtml+xml",
      "Accept-Language": "ja-JP,ja;q=0.9",
    },
  });

  if (!response.ok) {
    throw new Error(`Yahoo fetch failed: ${response.status} ${url}`);
  }

  return response.text();
}

export function formatDateInJst(date: Date): string {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Tokyo",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(date);
}

export function schedulePathForDate(date: Date): string {
  const dateParam = formatDateInJst(date);
  return `/npb/schedule/first/all?date=${dateParam}`;
}

export function gameIndexPath(gameId: string): string {
  return `/npb/game/${gameId}/index`;
}

export function gameScorePath(gameId: string): string {
  return `/npb/game/${gameId}/score`;
}
