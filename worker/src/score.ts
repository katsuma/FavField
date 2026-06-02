import { buildScoreResponse } from "./format";
import { fetchGameDetails, scheduleGameToDetails } from "./scraper/game";
import { fetchHtml, schedulePathForDate } from "./scraper/http";
import {
  findTeamGame,
  parseScheduleGames,
  pickBestGame,
} from "./scraper/schedule";
import { getTeamByAbbr, TEAMS } from "./teams";
import type { ScoreResponse } from "./types";

export async function getScoreForTeam(abbr: string): Promise<ScoreResponse> {
  const team = getTeamByAbbr(abbr);
  if (!team) {
    throw new InvalidTeamError(abbr);
  }

  const now = new Date();
  const yesterday = new Date(now);
  yesterday.setDate(yesterday.getDate() - 1);

  const [todayHtml, yesterdayHtml] = await Promise.all([
    fetchHtml(schedulePathForDate(now)),
    fetchHtml(schedulePathForDate(yesterday)),
  ]);

  const todayGame = findTeamGame(parseScheduleGames(todayHtml), team.id);
  const yesterdayGame = findTeamGame(
    parseScheduleGames(yesterdayHtml),
    team.id,
  );
  const selected = pickBestGame(todayGame, yesterdayGame);

  if (!selected) {
    return buildScoreResponse({
      status: "none",
      homeTeamId: team.id,
      awayTeamId: team.id,
      homeScore: null,
      awayScore: null,
      inning: null,
      half: null,
      startTime: null,
      gameId: null,
    });
  }

  let details = scheduleGameToDetails(selected);

  if (
    details.status === "live" ||
    (details.status === "final" &&
      (details.homeScore === null || details.awayScore === null))
  ) {
    details = await fetchGameDetails(fetchHtml, selected.gameId, details);
  }

  return buildScoreResponse({
    status: details.status,
    homeTeamId: details.homeTeamId,
    awayTeamId: details.awayTeamId,
    homeScore: details.homeScore,
    awayScore: details.awayScore,
    inning: details.inning,
    half: details.half,
    startTime: details.startTime,
    gameId: selected.gameId,
  });
}

export class InvalidTeamError extends Error {
  constructor(abbr: string) {
    super(`Unknown team abbr: ${abbr}`);
    this.name = "InvalidTeamError";
  }
}

export function listTeams() {
  return TEAMS.map(({ id, abbr, name }) => ({ id, abbr, name }));
}
