# Companion and Session-Loop Patterns

- Updated: 2026-05-26
- Sources: GTO Wizard (Unknown); Untapped.gg (Unknown); Mobalytics (2021-06-01)
- Raw: [GTO Wizard homepage](../../raw/product/2026-05-26-gto-wizard-homepage.md); [Untapped.gg Companion for MTG Arena](../../raw/product/2026-05-26-untapped-mtg-arena-companion.md); [Mobalytics homepage](../../raw/product/2021-06-01-mobalytics-homepage.md)

## Summary

Three recurring patterns show up across mature coaching/companion products:

1. automatic or near-automatic ingestion of played games
2. session-level leak tracking rather than one-game-only feedback
3. a full practice loop that connects review to drills and future decisions

## Automatic ingestion beats manual friction

- GTO Wizard emphasizes automatic hand-history uploads and post-game auto-sync.
- Untapped emphasizes a companion app that integrates directly with the game and continuously tracks match history and stats.

For this Pokémon project, this suggests a roadmap of manual paste/upload first, then optional desktop convenience import later.

## Session-level analytics matter

- Untapped highlights match history, rank progress, deck performance, and matchup statistics.
- GTO Wizard highlights leak finding and fully analyzed sessions.
- Mobalytics frames improvement around recurring strengths and weaknesses, not just one-off mistakes.

The coaching app should therefore store match findings over time and expose repeat patterns such as:

- repeated sequencing errors
- recurring missed KOs
- matchup-specific struggles
- deck-specific weak openings or resource habits

## Review should feed practice

GTO Wizard's strongest product pattern is the bridge from analysis to practice:

- find leaks
- create custom drills
- get instant feedback

That is a strong model for Pokémon: each reviewed match should ideally end in one concrete practice target or quizable board state.

## Improvement is a loop, not a screen

Mobalytics makes the loop explicit: before, during, after, and between games.

For Pokémon TCG, the likely adaptation is:

- before: matchup notes, opening priorities, prize-map reminders
- during: probably out of MVP scope due to integrity and integration risk
- after: post-game review from logs
- between: leak tracking, drills, and deck-adjustment notes

## Product implication

The right long-term shape is not just a replay viewer or a one-shot review tool. It is a training loop:

- ingest match
- review key moments
- track repeat leaks
- assign next habit or drill
- measure whether the leak improves over time

## See Also

- [Learning-Science Patterns for Practice Tools](learning-science-patterns-for-practice-tools.md)
- [Post-Game Review Patterns](post-game-review-patterns.md)
- [Pokémon TCG Coach MVP](pokemon-tcg-coach-mvp.md)
