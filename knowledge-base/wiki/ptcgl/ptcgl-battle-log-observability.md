# PTCGL Battle Log Observability

- Updated: 2026-05-26
- Sources: asherkobin (Unknown); exinmusic (Unknown); kagd (Unknown)
- Raw: [PTCGL Replay setup log sample](../../raw/ptcgl/2026-05-26-ptcgl-replay-setup-log.md); [Pokémon TCG battle replay sample log](../../raw/ptcgl/2026-05-26-pokemon-tcg-battle-replay-sample-log.md); [TCG Live log parser patterns](../../raw/ptcgl/2026-05-26-tcg-live-log-parser-patterns.md); [Pokémon TCG Battle Replay Parser](../../raw/ptcgl/2026-05-26-pokemon-tcg-battle-replay-parser-readme.md)

## Summary

Raw PTCGL-style logs expose enough public game state for a strong post-game coaching MVP. They are especially good at setup, revealed cards, card usage, board transitions, combat, prizes, and win conditions. They are weak at hidden-state reconstruction and full deterministic simulation.

## Reliably visible in the sampled logs

- opening coin flip choice, winner, and first/second decision
- opening-hand draw counts
- some explicit opening-hand card names and mulligan reveals
- active and bench placement
- evolutions and switches into the Active Spot
- attachments, trainer plays, stadium plays, and named abilities
- attacks, damage amounts, and some damage-breakdown explanations
- knockouts and prize-taking
- discarded cards, shuffle notices, and some search targets
- final win conditions such as deck-out

## Visible but format-sensitive / partial

- card identifiers in some logs, plain names in others
- generic turn markers like `"[playerName]'s Turn"`
- detailed discard / move lines that some parsers choose to skip as noise
- exact search mechanics vs. summarized "drew X and played it to the Bench" lines

## Not reliably visible from these sources alone

- exact hidden hand contents unless revealed
- unrevealed prize cards
- full opponent decklists
- a perfect action-time or clock model
- authoritative state snapshots after every effect resolves

## MVP implications

Strong first-wave coaching rules should target public-state mistakes:

- missed visible KO or lethal
- redundant gust or over-commitment for the same outcome
- obvious sequencing mistakes around search/draw/benching
- prize-race and board-pressure summaries

Rules that depend heavily on hidden state should be treated as low-confidence or LLM-assisted commentary rather than deterministic judgments.

## See Also

- [PTCGL Match Data Sources](ptcgl-match-data-sources.md)
- [Pokémon TCG Coach MVP](../product/pokemon-tcg-coach-mvp.md)
