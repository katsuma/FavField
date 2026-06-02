import { getTeamById } from "./teams";
import type { GameStatus, Half, ScoreResponse } from "./types";

interface DisplayInput {
  status: GameStatus;
  homeTeamId: number;
  awayTeamId: number;
  homeScore: number | null;
  awayScore: number | null;
  inning: number | null;
  half: Half | null;
  startTime: string | null;
}

export function buildDisplay(input: DisplayInput): string {
  const away = getTeamById(input.awayTeamId);
  const home = getTeamById(input.homeTeamId);

  if (!away || !home) {
    return "試合情報なし";
  }

  if (input.status === "none") {
    return `${away.abbr} 試合なし`;
  }

  if (input.status === "cancelled") {
    return `${away.abbr} - ${home.abbr} 中止`;
  }

  if (input.status === "pre") {
    const time = input.startTime ?? "--:--";
    return `${away.abbr} - ${home.abbr} ${time}`;
  }

  const awayScore = input.awayScore ?? 0;
  const homeScore = input.homeScore ?? 0;
  let display = `${away.abbr} ${awayScore}-${homeScore} ${home.abbr}`;

  if (input.status === "live" && input.inning !== null && input.half !== null) {
    display += ` ${input.inning}${input.half}`;
  }

  return display;
}

export function buildScoreResponse(
  input: DisplayInput & { gameId: string | null },
): ScoreResponse {
  const awayTeam = getTeamById(input.awayTeamId);
  const homeTeam = getTeamById(input.homeTeamId);

  return {
    status: input.status,
    away: {
      abbr: awayTeam?.abbr ?? "?",
      name: awayTeam?.name ?? "不明",
      score: input.awayScore,
    },
    home: {
      abbr: homeTeam?.abbr ?? "?",
      name: homeTeam?.name ?? "不明",
      score: input.homeScore,
    },
    inning: input.inning,
    half: input.half,
    startTime: input.startTime,
    display: buildDisplay(input),
    gameId: input.gameId,
    updatedAt: new Date().toISOString(),
  };
}

export function parseInningLabel(label: string): {
  inning: number;
  half: Half;
} | null {
  const match = label.match(/(\d+)回(表|裏)/);
  if (!match) {
    return null;
  }

  return {
    inning: Number.parseInt(match[1], 10),
    half: match[2] as Half,
  };
}

export function classifyStatusLabel(label: string): GameStatus {
  if (!label) {
    return "none";
  }

  if (label.includes("試合終了")) {
    return "final";
  }

  if (label.includes("試合中止")) {
    return "cancelled";
  }

  if (parseInningLabel(label)) {
    return "live";
  }

  if (label.includes("見どころ") || label.includes("試合前")) {
    return "pre";
  }

  return "none";
}
