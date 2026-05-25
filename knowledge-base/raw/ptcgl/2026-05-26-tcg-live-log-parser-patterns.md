# TCG Live log parser patterns

- Source: https://raw.githubusercontent.com/exinmusic/tcg-live-logs/main/src/parser/patterns.ts
- Collected: 2026-05-26
- Published: Unknown

## Excerpts

The parser defines explicit regex patterns for:

- setup: `coinFlipChoice`, `coinFlipWinner`, `goFirst`, `openingHand`, `mulligan`, `mulliganDraw`
- turn markers: `turnStart`
- draw actions: `drewCard`, `drewCards`
- Pokémon actions: `playedPokemon`, `evolved`, `switchedIn`
- attachments: `attachedEnergy`
- trainer cards: `playedTrainer`, `playedStadium`
- abilities: `usedAbility`
- combat: `attack`, `damageCounters`, `knockout`, `prizeTaken`
- coin flips: `coinFlip`
- win conditions: `deckOut`, `prizeWin`, `noPokemon`, `concede`
- detail helpers: `cardList`, `drewAndPlayed`, `drewSpecificCard`

The parser also declares skip patterns for metadata/noise such as card-list bullets, generic shuffle notices, and certain move/discard lines.

Notable limitation in the source: turn markers are matched as the literal string `"[playerName]'s Turn"`, which suggests parser robustness may depend on the exact log export format.
