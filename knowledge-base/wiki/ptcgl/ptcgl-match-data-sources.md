# PTCGL Match Data Sources

- Updated: 2026-05-26
- Sources: The Pokémon Company International (Unknown); kagd (Unknown); GitHub/asherkobin (Unknown); exinmusic (Unknown)
- Raw: [Pokémon TCG Live](../../raw/ptcgl/2026-05-26-pokemon-tcg-live-overview.md); [Pokémon TCG Battle Replay Parser](../../raw/ptcgl/2026-05-26-pokemon-tcg-battle-replay-parser-readme.md); [PTCGL Replay repo page](../../raw/ptcgl/2026-05-26-ptcgl-replay-repo-page.md); [PTCGL Replay setup log sample](../../raw/ptcgl/2026-05-26-ptcgl-replay-setup-log.md); [Pokémon TCG battle replay sample log](../../raw/ptcgl/2026-05-26-pokemon-tcg-battle-replay-sample-log.md)

## Summary

Pokémon TCG Live is the official digital play surface, but the ingested sources do not show an official match-history or coaching API. The best current match-data path is community battle-log tooling that consumes plain-text logs and converts them into structured representations.

## Official surface

- The official PTCGL page positions the game as the digital version of the physical TCG and emphasizes Standard play, private battles, matchmaking, and Learning Lab tutorials.
- The official page links to downloads, patch notes/news, support, terms, and privacy, but the ingested material does not expose a documented replay or match-history export API.

## Community log tooling

- [Pokémon TCG Battle Replay Parser](../../raw/ptcgl/2026-05-26-pokemon-tcg-battle-replay-parser-readme.md) explicitly says it parses "Pokémon TCG Live battle logs" into JSON and tracks setup, actions, attacks, prizes, turn progression, and outcome.
- [PTCGL Replay repo page](../../raw/ptcgl/2026-05-26-ptcgl-replay-repo-page.md) shows a public repo with `logs/`, `modules/`, HTML, and JS files, which is consistent with a standalone replay viewer built around local log files.

## Practical implication

For a coaching MVP, the safest ingestion contract is:

1. Player pastes or uploads a raw battle log.
2. The app parses it into structured events.
3. Enrichment APIs add card/deck/tournament context.
4. Coaching logic produces post-game findings.

This avoids depending on an undocumented live API or unstable automation against the running client.

## Known limitations

- The sources confirm community access to battle logs, not official support for third-party ingestion.
- Community tooling varies in maturity: one parser is rule/AI-based, while the replay viewer repo has minimal documentation.

## See Also

- [PTCGL Battle Log Observability](ptcgl-battle-log-observability.md)
- [Card and Tournament Data Sources](../data/card-and-tournament-data-sources.md)
- [Pokémon TCG Coach MVP](../product/pokemon-tcg-coach-mvp.md)
