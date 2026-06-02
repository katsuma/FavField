import { describe, expect, it } from "vitest";
import { buildDisplay, classifyStatusLabel, parseInningLabel } from "../src/format";
import { parseScheduleGames } from "../src/scraper/schedule";

const finishedGameHtml = `
<li class="bb-score__item">
  <a class="bb-score__content" href="/npb/game/2021038945/index">
    <div class="bb-score__team">
      <p class="bb-score__homeLogo bb-score__homeLogo--npbTeam1">巨人</p>
      <p class="bb-score__awayLogo bb-score__awayLogo--npbTeam11">オリックス</p>
    </div>
    <div class="bb-score__info">
      <div class="bb-score__wrap">
        <div class="bb-score__detail">
          <p class="bb-score__status">
            <span class="bb-score__score bb-score__score--left">3</span>
            <span class="bb-score__score bb-score__score--center">-</span>
            <span class="bb-score__score bb-score__score--right">2</span>
          </p>
          <p class="bb-score__link">試合終了</p>
        </div>
      </div>
    </div>
  </a>
</li>
`;

const preGameHtml = `
<li class="bb-score__item">
  <a class="bb-score__content" href="/npb/game/2021038955/index">
    <div class="bb-score__team">
      <p class="bb-score__homeLogo bb-score__homeLogo--npbTeam5">阪神</p>
      <p class="bb-score__awayLogo bb-score__awayLogo--npbTeam7">西武</p>
    </div>
    <div class="bb-score__info">
      <div class="bb-score__wrap">
        <div class="bb-score__detail">
          <time class="bb-score__status">18:00</time>
          <p class="bb-score__link">見どころ</p>
        </div>
      </div>
    </div>
  </a>
</li>
`;

describe("parseInningLabel", () => {
  it("parses live inning labels", () => {
    expect(parseInningLabel("7回裏")).toEqual({ inning: 7, half: "裏" });
    expect(parseInningLabel("1回表")).toEqual({ inning: 1, half: "表" });
  });
});

describe("classifyStatusLabel", () => {
  it("classifies known labels", () => {
    expect(classifyStatusLabel("試合終了")).toBe("final");
    expect(classifyStatusLabel("7回裏")).toBe("live");
    expect(classifyStatusLabel("見どころ")).toBe("pre");
    expect(classifyStatusLabel("試合中止")).toBe("cancelled");
  });
});

describe("parseScheduleGames", () => {
  it("parses finished and pre-game cards", () => {
    const games = parseScheduleGames(`${finishedGameHtml}${preGameHtml}`);

    expect(games).toHaveLength(2);

    expect(games[0]).toMatchObject({
      gameId: "2021038945",
      homeTeamId: 1,
      awayTeamId: 11,
      status: "final",
      homeScore: 3,
      awayScore: 2,
    });

    expect(games[1]).toMatchObject({
      gameId: "2021038955",
      homeTeamId: 5,
      awayTeamId: 7,
      status: "pre",
      startTime: "18:00",
    });
  });
});

describe("buildDisplay", () => {
  it("formats final and pre-game displays", () => {
    expect(
      buildDisplay({
        status: "final",
        homeTeamId: 1,
        awayTeamId: 11,
        homeScore: 3,
        awayScore: 2,
        inning: null,
        half: null,
        startTime: null,
      }),
    ).toBe("B 2-3 G");

    expect(
      buildDisplay({
        status: "pre",
        homeTeamId: 5,
        awayTeamId: 7,
        homeScore: null,
        awayScore: null,
        inning: null,
        half: null,
        startTime: "18:00",
      }),
    ).toBe("L - T 18:00");

    expect(
      buildDisplay({
        status: "live",
        homeTeamId: 1,
        awayTeamId: 5,
        homeScore: 0,
        awayScore: 1,
        inning: 7,
        half: "裏",
        startTime: null,
      }),
    ).toBe("T 1-0 G 7裏");
  });
});
