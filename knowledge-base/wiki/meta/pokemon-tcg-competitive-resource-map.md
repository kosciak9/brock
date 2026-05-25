# Pokémon TCG Competitive Resource Map

- Updated: 2026-05-26
- Sources: Limitless (Unknown); Robin Schulz / Limitless (2025-04-19); JustInBasil (Unknown); TrainerHill (Unknown)
- Raw: [Limitless About](../../raw/meta/2026-05-26-limitless-about.md); [Limitless Labs Launch](../../raw/meta/2025-04-19-limitless-labs-launch.md); [JustInBasil deck-building guide](../../raw/meta/2026-05-26-justinbasil-deck-building-guide.md); [JustInBasil external resources](../../raw/meta/2026-05-26-justinbasil-external-resources.md); [TrainerHill sitemap](../../raw/meta/2026-05-26-trainerhill-sitemap.md)

## Summary

The competitive Pokémon TCG ecosystem splits into three broad buckets:

- archival/tournament coverage (Limitless)
- manual analysis and deckbuilding heuristics (JustInBasil, TrainerHill, PokéStats)
- direct tournament-platform APIs (TopDeck, covered separately)

## Limitless

Limitless is the strongest public competitive database in the ingested sources:

- tournament history
- decklists
- player records
- card database
- auxiliary tools

Limitless Labs adds deeper event views when full decklist publication is available, including:

- what decks players faced
- day 1 metagame summaries
- matchup win rates
- deck conversion rates

## JustInBasil

JustInBasil is valuable less as a live data source and more as a coaching taxonomy source. Its guide breaks gameplay and deck construction into useful buckets such as:

- search
- gusting
- energy/acceleration
- consistency/setup
- switching/prize denial
- recovery/rebound
- disruption
- damage control

Those categories can inform how coaching findings are grouped and explained.

## TrainerHill

Within the ingested sources, TrainerHill appears as an established competitive resource and public tool surface:

- listed by JustInBasil under competitive resources
- public sitemap includes `/meta`, `/cards`, `/decklist`, and multiple `/tools/...` routes

Based on the currently ingested sources alone, TrainerHill is best treated as a manual/reference resource rather than a documented developer platform.

## Practical use for this project

- Lean on Limitless/TopDeck for meta and event context.
- Lean on JustInBasil for terminology and mistake taxonomy.
- Use TrainerHill manually for research and inspiration until a stable integration path is documented.

## See Also

- [Card and Tournament Data Sources](../data/card-and-tournament-data-sources.md)
- [Pokémon TCG Practice Tool Surface](pokemon-tcg-practice-tool-surface.md)
- [Pokémon TCG Coach MVP](../product/pokemon-tcg-coach-mvp.md)
