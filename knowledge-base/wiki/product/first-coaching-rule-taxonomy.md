# First Coaching-Rule Taxonomy

- Updated: 2026-05-26
- Sources: exinmusic (Unknown); kagd (Unknown); JustInBasil (Unknown); Chess.com (2025-05-06)
- Raw: [Pokémon TCG battle replay sample log](../../raw/ptcgl/2026-05-26-pokemon-tcg-battle-replay-sample-log.md); [TCG Live log parser patterns](../../raw/ptcgl/2026-05-26-tcg-live-log-parser-patterns.md); [JustInBasil deck-building guide](../../raw/meta/2026-05-26-justinbasil-deck-building-guide.md); [Chess.com Game Review](../../raw/product/2025-05-06-chesscom-game-review.md)

## Summary

The first coaching rules should optimize for trust, not coverage. A good v1 rule is one that can be explained with visible evidence from the log and mapped to a simple category the player already understands.

## Strong v1 categories

Using JustInBasil's gameplay categories and the observed log fields, the best first rule buckets are:

- search / setup
- gusting
- switching / pivoting
- recovery / rebound
- damage control / prize pressure
- sequencing

## Recommended first deterministic rules

### 1. Missed visible KO

Flag turns where the public log shows a clear attack or line that would have taken a KO, but the chosen action did not.

### 2. Missed visible lethal / prize-closing line

Flag turns where the player had a visible route to take the last prizes or force an immediate winning swing.

### 3. Redundant gust

Flag gust effects that do not improve prize tempo, remove a key threat, or create a better line than attacking the already-active target.

### 4. Obvious sequencing inefficiency

Flag simple ordering mistakes that are visible from the log, especially where a player commits before gathering obvious information or uses a narrower search line before a broader one.

### 5. Resource overpay for same outcome

Flag turns where a gust, stadium, switch, tool, or premium card is spent for an outcome that was already available more cheaply.

### 6. Missed pivot / switching line

Flag turns where the player strands the wrong active Pokémon despite a visible switch or retreat line that would better preserve pressure.

## Medium-confidence rule families

These are useful, but should probably start as softer notes rather than hard "mistake" labels:

- bench-liability creation
- recovery timing
- prize-map errors
- spread/snipe setup misses
- matchup-plan drift

These often require more context than the log alone can guarantee.

## Suggested review labels

Borrowing the spirit of Chess.com's move classification without copying its exact taxonomy, a Pokémon coach can start with:

- strong line
- miss
- mistake
- major mistake
- forced line

This is likely enough for MVP. Too many labels will feel fake before the rule engine is mature.

## Rule-writing principles

- Every finding should cite turn/action evidence.
- Every finding should separate observation from inference.
- If hidden-state assumptions are required, downgrade confidence.
- Prefer one high-confidence note over three shaky ones.

## Practical build order

1. missed visible KO
2. missed visible lethal
3. redundant gust
4. sequencing inefficiency
5. resource overpay
6. pivot / switching line

## See Also

- [PTCGL Battle Log Observability](../ptcgl/ptcgl-battle-log-observability.md)
- [Post-Game Review Patterns](post-game-review-patterns.md)
- [Pokémon TCG Coach MVP](pokemon-tcg-coach-mvp.md)
