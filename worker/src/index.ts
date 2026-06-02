import { getScoreForTeam, InvalidTeamError, listTeams } from "./score";

export interface Env {
  CACHE_TTL_SECONDS?: string;
}

const DEFAULT_CACHE_TTL = 45;

function jsonResponse(body: unknown, init: ResponseInit = {}): Response {
  const headers = new Headers(init.headers);
  headers.set("Content-Type", "application/json; charset=utf-8");
  headers.set("Access-Control-Allow-Origin", "*");

  return new Response(JSON.stringify(body), {
    ...init,
    headers,
  });
}

function getCacheTtl(env: Env): number {
  const parsed = Number.parseInt(env.CACHE_TTL_SECONDS ?? "", 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : DEFAULT_CACHE_TTL;
}

async function getCachedScore(
  request: Request,
  env: Env,
  team: string,
): Promise<Response> {
  const cache = caches.default;
  const cacheKey = new Request(
    new URL(`/score?team=${team.toUpperCase()}`, request.url).toString(),
    request,
  );

  const cached = await cache.match(cacheKey);
  if (cached) {
    return cached;
  }

  const payload = await getScoreForTeam(team);
  const response = jsonResponse(payload, {
    headers: {
      "Cache-Control": `public, max-age=${getCacheTtl(env)}`,
    },
  });

  await cache.put(cacheKey, response.clone());
  return response;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (request.method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type",
        },
      });
    }

    if (request.method !== "GET") {
      return jsonResponse({ error: "Method not allowed" }, { status: 405 });
    }

    if (url.pathname === "/health") {
      return jsonResponse({ ok: true });
    }

    if (url.pathname === "/teams") {
      return jsonResponse({ teams: listTeams() });
    }

    if (url.pathname === "/score") {
      const team = url.searchParams.get("team");
      if (!team) {
        return jsonResponse(
          {
            error: "Missing query parameter: team",
            example: "/score?team=T",
            teams: listTeams(),
          },
          { status: 400 },
        );
      }

      try {
        return await getCachedScore(request, env, team);
      } catch (error) {
        if (error instanceof InvalidTeamError) {
          return jsonResponse(
            {
              error: error.message,
              teams: listTeams(),
            },
            { status: 400 },
          );
        }

        console.error(error);
        return jsonResponse(
          { error: "Failed to fetch score from Yahoo Sports" },
          { status: 502 },
        );
      }
    }

    return jsonResponse(
      {
        error: "Not found",
        endpoints: ["/score?team=T", "/teams", "/health"],
      },
      { status: 404 },
    );
  },
};
