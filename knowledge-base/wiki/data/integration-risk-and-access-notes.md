# Integration Risk and Access Notes

- Updated: 2026-05-26
- Sources: The Pokémon Company International (Unknown); kagd (Unknown); Pokémon TCG API (Unknown); TopDeck.gg (Unknown); TCGdex (Unknown); TrainerHill (Unknown)
- Raw: [Pokémon TCG Live](../../raw/ptcgl/2026-05-26-pokemon-tcg-live-overview.md); [Pokémon TCG Battle Replay Parser](../../raw/ptcgl/2026-05-26-pokemon-tcg-battle-replay-parser-readme.md); [Pokémon TCG API docs](../../raw/data/2026-05-26-pokemon-tcg-api-docs.md); [TopDeck.gg API – Tournaments V2](../../raw/data/2026-05-26-topdeck-tournaments-v2-docs.md); [TCGdex API docs](../../raw/data/2026-05-26-tcgdex-api-docs.md); [TrainerHill sitemap](../../raw/meta/2026-05-26-trainerhill-sitemap.md)

## Summary

The current source set supports a clear access hierarchy for this project:

1. documented APIs with stable auth and usage rules
2. community/undocumented match-log tooling
3. manual/reference tools with no developer surface documented in the ingested sources

## Lowest-risk integrations

### Pokémon TCG API

- documented REST API
- free key model with published limits
- strong fit for card text, legality, and metadata

### TopDeck.gg

- documented REST API
- free API key in `Authorization`
- explicit attribution and rate-limit rules
- strongest current tournament/decklist API in the source set

### TCGdex

- documented REST + GraphQL
- no API key required
- multilingual and open-source

These three should be treated as the default stable integration layer.

## Medium-risk / community-dependent integration

### PTCGL battle logs

The source set shows community tooling that parses battle logs into JSON, but the official PTCGL page does not document a replay or match-history API.

Implication:

- good for MVP ingestion via paste/upload
- acceptable as a community-supported input path
- risky as a hard dependency for fully automated import until local-file behavior is directly verified

## Higher-risk / manual-only surface in current knowledge base

### TrainerHill

The currently ingested TrainerHill source is a sitemap plus third-party recommendation context from JustInBasil. That establishes TrainerHill as a useful public tool surface, but not as a documented integration platform.

Implication:

- good for manual research and inspiration
- not yet a safe primary dependency for product architecture

## Product guidance

Architect the app so that:

- core enrichment uses documented APIs
- gameplay ingestion can start manually
- manual/reference tools remain optional and replaceable

This keeps the coaching product useful even if community log formats or third-party sites change.

## See Also

- [Card and Tournament Data Sources](card-and-tournament-data-sources.md)
- [PTCGL Match Data Sources](../ptcgl/ptcgl-match-data-sources.md)
- [Pokémon TCG Competitive Resource Map](../meta/pokemon-tcg-competitive-resource-map.md)
- [Pokémon TCG Coach MVP](../product/pokemon-tcg-coach-mvp.md)
