import type { Element } from "domhandler";
import * as cheerio from "cheerio";
import { classifyStatusLabel, parseInningLabel } from "../format";
import { extractTeamId } from "../teams";
import type { GameStatus, Half, ParsedScheduleGame } from "../types";

function parseScore(value: string | undefined): number | null {
  if (!value?.trim()) {
    return null;
  }

  const parsed = Number.parseInt(value.trim(), 10);
  return Number.isNaN(parsed) ? null : parsed;
}

function parseScheduleItem(
  $: cheerio.CheerioAPI,
  element: Element,
): ParsedScheduleGame | null {
  const item = $(element);
  const href = item.find("a.bb-score__content").attr("href");
  const gameId = href?.match(/\/npb\/game\/(\d+)\//)?.[1];
  if (!gameId) {
    return null;
  }

  const homeTeamId = extractTeamId(
    item.find(".bb-score__homeLogo").attr("class"),
  );
  const awayTeamId = extractTeamId(
    item.find(".bb-score__awayLogo").attr("class"),
  );

  if (homeTeamId === null || awayTeamId === null) {
    return null;
  }

  const statusLabel = item.find(".bb-score__link").text().trim();
  const startTime = item.find("time.bb-score__status").text().trim() || null;
  const homeScore = parseScore(
    item.find(".bb-score__score--left").first().text(),
  );
  const awayScore = parseScore(
    item.find(".bb-score__score--right").first().text(),
  );

  let status: GameStatus = classifyStatusLabel(statusLabel);
  let inning: number | null = null;
  let half: Half | null = null;

  if (startTime) {
    status = "pre";
  }

  const inningInfo = parseInningLabel(statusLabel);
  if (inningInfo) {
    status = "live";
    inning = inningInfo.inning;
    half = inningInfo.half;
  }

  return {
    gameId,
    homeTeamId,
    awayTeamId,
    status,
    homeScore,
    awayScore,
    inning,
    half,
    startTime,
    statusLabel,
  };
}

export function parseScheduleGames(html: string): ParsedScheduleGame[] {
  const $ = cheerio.load(html);
  const games: ParsedScheduleGame[] = [];

  $("li.bb-score__item").each((_, element) => {
    const game = parseScheduleItem($, element);
    if (game) {
      games.push(game);
    }
  });

  return games;
}

export function findTeamGame(
  games: ParsedScheduleGame[],
  teamId: number,
): ParsedScheduleGame | undefined {
  return games.find(
    (game) => game.homeTeamId === teamId || game.awayTeamId === teamId,
  );
}

export function pickBestGame(
  todayGame: ParsedScheduleGame | undefined,
  yesterdayGame: ParsedScheduleGame | undefined,
): ParsedScheduleGame | undefined {
  if (todayGame) {
    if (todayGame.status === "live" || todayGame.status === "pre") {
      return todayGame;
    }

    if (todayGame.status === "final" || todayGame.status === "cancelled") {
      return todayGame;
    }
  }

  return yesterdayGame ?? todayGame;
}
