import * as cheerio from "cheerio";
import { classifyStatusLabel, parseInningLabel } from "../format";
import { extractTeamId } from "../teams";
import type { GameDetails, GameStatus, Half } from "../types";

function parseScore(value: string | undefined): number | null {
  if (!value?.trim()) {
    return null;
  }

  const parsed = Number.parseInt(value.trim(), 10);
  return Number.isNaN(parsed) ? null : parsed;
}

function parseGamePage(html: string): GameDetails | null {
  const $ = cheerio.load(html);

  const homeLink = $("#async-gameDetail .bb-gameTeam").first();
  const awayLink = $("#async-gameDetail .bb-gameTeam").last();

  const homeTeamId =
    extractTeamId(homeLink.find(".bb-teamLogo").attr("class")) ??
    extractTeamId(homeLink.find("[class*='npbTeam']").attr("class"));
  const awayTeamId =
    extractTeamId(awayLink.find(".bb-teamLogo").attr("class")) ??
    extractTeamId(awayLink.find("[class*='npbTeam']").attr("class"));

  if (homeTeamId === null || awayTeamId === null) {
    return null;
  }

  const homeScore = parseScore($(".bb-gameTeam__homeScore").first().text());
  const awayScore = parseScore($(".bb-gameTeam__awayScore").first().text());
  const statusLabel = $(".bb-gameCard__state span").first().text().trim();
  const startTime = $("time.bb-gameCard__time").first().text().trim() || null;

  let status: GameStatus = classifyStatusLabel(statusLabel);
  let inning: number | null = null;
  let half: Half | null = null;

  if (startTime && status === "none") {
    status = "pre";
  }

  const inningInfo = parseInningLabel(statusLabel);
  if (inningInfo) {
    status = "live";
    inning = inningInfo.inning;
    half = inningInfo.half;
  }

  return {
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

function parseLiveScorePage(html: string): Pick<
  GameDetails,
  "status" | "homeScore" | "awayScore" | "inning" | "half" | "statusLabel"
> | null {
  const $ = cheerio.load(html);
  const statusLabel = $("#liveHeader h4.live em").first().text().trim();

  if (!statusLabel) {
    return null;
  }

  let status: GameStatus = classifyStatusLabel(statusLabel);
  let inning: number | null = null;
  let half: Half | null = null;

  const inningInfo = parseInningLabel(statusLabel);
  if (inningInfo) {
    status = "live";
    inning = inningInfo.inning;
    half = inningInfo.half;
  }

  const rows = $("#liveHeader .score table tr");
  let awayScore: number | null = null;
  let homeScore: number | null = null;

  if (rows.length >= 2) {
    awayScore = parseScore($(rows[0]).find("td").last().text());
    homeScore = parseScore($(rows[1]).find("td").last().text());
  }

  return {
    status,
    homeScore,
    awayScore,
    inning,
    half,
    statusLabel,
  };
}

export async function fetchGameDetails(
  fetchHtml: (path: string) => Promise<string>,
  gameId: string,
  fallback: GameDetails,
): Promise<GameDetails> {
  const [indexHtml, scoreHtml] = await Promise.all([
    fetchHtml(`/npb/game/${gameId}/index`),
    fetchHtml(`/npb/game/${gameId}/score`),
  ]);

  const indexDetails = parseGamePage(indexHtml);
  const liveDetails = parseLiveScorePage(scoreHtml);

  if (!indexDetails && !liveDetails) {
    return fallback;
  }

  const merged: GameDetails = {
    homeTeamId: indexDetails?.homeTeamId ?? fallback.homeTeamId,
    awayTeamId: indexDetails?.awayTeamId ?? fallback.awayTeamId,
    status: fallback.status,
    homeScore: indexDetails?.homeScore ?? fallback.homeScore,
    awayScore: indexDetails?.awayScore ?? fallback.awayScore,
    inning: indexDetails?.inning ?? fallback.inning,
    half: indexDetails?.half ?? fallback.half,
    startTime: indexDetails?.startTime ?? fallback.startTime,
    statusLabel: indexDetails?.statusLabel ?? fallback.statusLabel,
  };

  if (liveDetails) {
    if (liveDetails.status !== "none") {
      merged.status = liveDetails.status;
    }
    if (liveDetails.homeScore !== null) {
      merged.homeScore = liveDetails.homeScore;
    }
    if (liveDetails.awayScore !== null) {
      merged.awayScore = liveDetails.awayScore;
    }
    if (liveDetails.inning !== null) {
      merged.inning = liveDetails.inning;
    }
    if (liveDetails.half !== null) {
      merged.half = liveDetails.half;
    }
    if (liveDetails.statusLabel) {
      merged.statusLabel = liveDetails.statusLabel;
    }
  }

  if (merged.status === "none" && merged.homeScore !== null) {
    merged.status = "final";
  }

  return merged;
}

export function scheduleGameToDetails(
  game: import("../types").ParsedScheduleGame,
): GameDetails {
  return {
    homeTeamId: game.homeTeamId,
    awayTeamId: game.awayTeamId,
    status: game.status,
    homeScore: game.homeScore,
    awayScore: game.awayScore,
    inning: game.inning,
    half: game.half,
    startTime: game.startTime,
    statusLabel: game.statusLabel,
  };
}
