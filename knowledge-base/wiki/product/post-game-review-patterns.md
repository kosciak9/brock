# Post-Game Review Patterns

- Updated: 2026-05-26
- Sources: Chess.com (2025-05-06)
- Raw: [Chess.com Game Review](../../raw/product/2025-05-06-chesscom-game-review.md)

## Summary

Chess.com's Game Review flow is a strong reference for a Pokémon TCG post-game coach because it keeps the review compact, classifies moments, highlights only key turns, and offers a retry loop instead of drowning the player in every move.

## Reusable patterns

### Immediate post-game entry point

Review starts directly from the game-over surface. For a Pokémon coach, the equivalent is: paste/upload log, then immediately see the review.

### One-screen highlights first

Chess.com starts with a highlights screen and a one-line story of the game. A Pokémon version should lead with:

- result
- turning turn
- biggest mistake or missed line
- one habit for the next set of games

### Classified moments

Chess.com classifies moves. A Pokémon version can classify turns or decisions as:

- strong line
- miss
- mistake
- major mistake
- forced line

### Key moments only

The review focuses on key moves, not every move. That maps well to Pokémon, where only a few turns usually matter most.

### Retry loop

Chess.com lets the player retry a critical move. A Pokémon version should eventually support a "What would you do here?" quiz on flagged turns.

### Opponent perspective

Chess.com explicitly supports reviewing from the opponent perspective. In Pokémon this would help explain why an opponent line was threatening or why a bench/gust liability mattered.

## MVP takeaway

The first Pokémon review screen should be short, evidence-based, and centered on 3–5 moments maximum.

## See Also

- [Companion and Session-Loop Patterns](companion-and-session-loop-patterns.md)
- [Pokémon TCG Coach MVP](pokemon-tcg-coach-mvp.md)
- [PTCGL Battle Log Observability](../ptcgl/ptcgl-battle-log-observability.md)
