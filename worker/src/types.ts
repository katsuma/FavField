export type GameStatus = "pre" | "live" | "final" | "cancelled" | "none";

export type Half = "表" | "裏";

export interface TeamInfo {
  id: number;
  abbr: string;
  name: string;
}

export interface TeamScore {
  abbr: string;
  name: string;
  score: number | null;
}

export interface ScoreResponse {
  status: GameStatus;
  away: TeamScore;
  home: TeamScore;
  inning: number | null;
  half: Half | null;
  startTime: string | null;
  display: string;
  gameId: string | null;
  updatedAt: string;
}

export interface ParsedScheduleGame {
  gameId: string;
  homeTeamId: number;
  awayTeamId: number;
  status: GameStatus;
  homeScore: number | null;
  awayScore: number | null;
  inning: number | null;
  half: Half | null;
  startTime: string | null;
  statusLabel: string;
}

export interface GameDetails {
  homeTeamId: number;
  awayTeamId: number;
  status: GameStatus;
  homeScore: number | null;
  awayScore: number | null;
  inning: number | null;
  half: Half | null;
  startTime: string | null;
  statusLabel: string;
}
