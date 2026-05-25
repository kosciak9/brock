# Card and Tournament Data Sources

- Updated: 2026-05-26
- Sources: Pokémon TCG API (Unknown); TopDeck.gg (Unknown); TCGdex (Unknown)
- Raw: [Pokémon TCG API docs](../../raw/data/2026-05-26-pokemon-tcg-api-docs.md); [TopDeck.gg API – Tournaments V2](../../raw/data/2026-05-26-topdeck-tournaments-v2-docs.md); [TCGdex API docs](../../raw/data/2026-05-26-tcgdex-api-docs.md)

## Summary

For a coaching app, the cleanest enrichment stack is:

- Pokémon TCG API for card text, legality, and broad card metadata
- TopDeck for tournament, standings, decklists, and round-level event context
- TCGdex for multilingual/open-source card data and a no-key fallback

## Pokémon TCG API

Best use:

- card lookup and deck enrichment
- card text, attacks, abilities, retreat, weaknesses, legality, images
- broad SDK availability

Access model:

- supports unauthenticated use
- higher limits with free `X-Api-Key`
- documented limits: 20,000/day with key, 1,000/day and 30/min without key

## TopDeck.gg

Best use:

- tournament search
- standings and player records
- decklists and structured `deckObj` when available
- round and table data for event narratives

Access model:

- free API key in `Authorization` header
- attribution required
- most endpoints limited to 100 requests/minute

Important caveat:

- decklists are conditional on event completion or organizer settings

## TCGdex

Best use:

- multilingual card and set data
- open-source data model
- GraphQL and REST access
- TCG Live-oriented card-data guidance

Access model:

- no API key required
- no published hard rate limits, but caching is recommended

## Recommended app role split

- Use Pokémon TCG API as the default primary card service.
- Use TCGdex as a multilingual or resilience fallback.
- Use TopDeck for matchup/archetype/tournament context around decks and players.

## See Also

- [Integration Risk and Access Notes](integration-risk-and-access-notes.md)
- [PTCGL Match Data Sources](../ptcgl/ptcgl-match-data-sources.md)
- [Pokémon TCG Competitive Resource Map](../meta/pokemon-tcg-competitive-resource-map.md)
- [Pokémon TCG Coach MVP](../product/pokemon-tcg-coach-mvp.md)
