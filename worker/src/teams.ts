import type { TeamInfo } from "./types";

export const TEAMS: TeamInfo[] = [
  { id: 1, abbr: "G", name: "巨人" },
  { id: 2, abbr: "S", name: "ヤクルト" },
  { id: 3, abbr: "DB", name: "DeNA" },
  { id: 4, abbr: "D", name: "中日" },
  { id: 5, abbr: "T", name: "阪神" },
  { id: 6, abbr: "C", name: "広島" },
  { id: 7, abbr: "L", name: "西武" },
  { id: 8, abbr: "F", name: "日本ハム" },
  { id: 9, abbr: "M", name: "ロッテ" },
  { id: 11, abbr: "B", name: "オリックス" },
  { id: 12, abbr: "H", name: "ソフトバンク" },
  { id: 376, abbr: "E", name: "楽天" },
];

const byId = new Map(TEAMS.map((team) => [team.id, team]));
const byAbbr = new Map(TEAMS.map((team) => [team.abbr.toUpperCase(), team]));

export function getTeamByAbbr(abbr: string): TeamInfo | undefined {
  return byAbbr.get(abbr.trim().toUpperCase());
}

export function getTeamById(id: number): TeamInfo | undefined {
  return byId.get(id);
}

export function extractTeamId(className: string | undefined): number | null {
  if (!className) {
    return null;
  }

  const match = className.match(/npbTeam(\d+)/);
  if (!match) {
    return null;
  }

  return Number.parseInt(match[1], 10);
}
