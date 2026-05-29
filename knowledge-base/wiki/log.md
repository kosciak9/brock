# Wiki Log

## [2026-05-29] implementation | Ability DSL Manifest Entry
- Added: Drakloak `Recon Directive` to `Brock.Tcg.Cards.Behaviors.TWM` as the first representative Ability behavior manifest entry
- Preserved: cached TCGdex Ability name and raw effect remain the static source of truth; the DSL entry only declares the executable effect overlay
- Verified: manifest check with `MIX_ENV=test mix run --no-start -e ...`, `mix test test/brock/tcg/cards/metadata_test.exs test/brock/tcg/sim/card_registry_test.exs`, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Plain-Damage DSL Manifest Entry
- Added: Dragapult ex `Jet Headbutt` to `Brock.Tcg.Cards.Behaviors.TWM` as the first representative plain-damage behavior manifest entry
- Preserved: static attack cost and damage continue to come from cached TCGdex metadata; the DSL entry adds no hand-written static fields
- Verified: `mix test test/brock/tcg/cards/metadata_test.exs test/brock/tcg/sim/card_registry_test.exs`, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Behavior DSL Foundation
- Added: `Brock.Tcg.Cards.DSL` compile-time card behavior overlay DSL with manifest helpers
- Guarded: DSL card, attack, and Ability references validate against committed TCGdex metadata and require executable `:effect` overlays when raw printed text exists
- Seeded: `Brock.Tcg.Cards.Behaviors.TWM` declares Dragapult ex `Phantom Dive` behavior manifest data without replacing the registry facade yet
- Verified: `mix test test/brock/tcg/cards/metadata_test.exs test/brock/tcg/sim/card_registry_test.exs`, `mix test test/brock/tcg/sim`, `mix brock.cards.coverage`, and `mix precommit` pass

## [2026-05-29] implementation | Metadata-Backed Registry Facade
- Added: `Brock.Tcg.Sim.CardRegistry.fetch/1` now builds supported card entries from cached `Brock.Tcg.Cards.Metadata` and overlays existing authored executable behavior
- Preserved: temporary compatibility shims for current reducer requirements, including Brock-ID evolution links, basic/special Energy classification, inferred basic Energy provides, and fallback weakness/resistance maps for cache gaps
- Guarded: `CardRegistry.fetch_attack/2` now rejects cached raw attack text with no executable overlay instead of exposing it as playable behavior
- Updated: `mix brock.cards.coverage` now reports `metadata_backed_registry` with `metadata_cached=44` for the fixed deck pool
- Verified: `mix test test/brock/tcg/sim/card_registry_test.exs test/brock/tcg/cards/metadata_test.exs`, `mix test test/brock/tcg/sim`, `mix brock.cards.coverage`, and `mix precommit` pass

## [2026-05-29] implementation | TCGdex Metadata Normalization
- Added: `Brock.Tcg.Cards.Metadata` offline reader for normalized metadata from committed TCGdex cache payloads
- Covered: representative Pokémon (`TWM-130`), Trainer (`TWM-165`), and Energy (`POR-088`) static fields while preserving raw printed effects for later behavior overlays
- Verified: `mix test test/brock/tcg/cards/metadata_test.exs`, `mix test test/brock/tcg/sim`, and `mix brock.cards.coverage` pass

## [2026-05-29] implementation | TCGdex Metadata Cache Foundation
- Added: `Brock.Tcg.Data.TCGdex` adapter/cache helper and opt-in `mix brock.cards.sync` network task
- Cached: TCGdex metadata for 15 deck-pool sets and 101 unique cards across the six known Limitless deck modules under `priv/tcg/cards/tcgdex`
- Verified: `mix brock.cards.sync` is cache-idempotent after generation with 101 cached cards and 0 written cards
- Verified: cached JSON excludes dynamic `"pricing":` fields while recording that pricing was removed
- Verified: `mix test test/brock/tcg/sim`, `mix brock.cards.coverage`, and `mix precommit` pass

## [2026-05-29] implementation | Rocket's Mewtwo Deck Import
- Added: `Brock.Tcg.Sim.Decks.RocketMewtwo27459` static deck module from Limitless deck 27459 using `Brock.Tcg.Sim.Decklist`
- Verified: source deck totals 60 cards from 15 Pokémon, 34 Trainer, and 11 Energy cards
- Verified: `mix test test/brock/tcg/sim` passes with 75 tests
- Verified: `mix brock.cards.coverage` still reports the current fixed-deck registry coverage successfully

## [2026-05-29] implementation | Lopunny Dudunsparce Deck Import
- Added: `Brock.Tcg.Sim.Decks.LopunnyDudunsparce27514` static deck module from Limitless deck 27514 using `Brock.Tcg.Sim.Decklist`
- Verified: source deck totals 60 cards from 17 Pokémon, 35 Trainer, and 8 Energy cards
- Verified: `mix test test/brock/tcg/sim` passes with 75 tests
- Verified: `mix brock.cards.coverage` still reports the current fixed-deck registry coverage successfully

## [2026-05-29] implementation | Festival Lead Deck Import
- Added: `Brock.Tcg.Sim.Decks.FestivalLead27445` static deck module from Limitless deck 27445 using `Brock.Tcg.Sim.Decklist`
- Verified: source deck totals 60 cards from 23 Pokémon, 32 Trainer, and 5 Energy cards
- Verified: `mix test test/brock/tcg/sim` passes with 75 tests
- Verified: `mix brock.cards.coverage` still reports the current fixed-deck registry coverage successfully

## [2026-05-29] implementation | Raging Bolt Ogerpon Deck Import
- Added: `Brock.Tcg.Sim.Decks.RagingBoltOgerpon27599` static deck module from Limitless deck 27599 using `Brock.Tcg.Sim.Decklist`
- Verified: source deck totals 60 cards from 19 Pokémon, 26 Trainer, and 15 Energy cards
- Verified: `mix test test/brock/tcg/sim` passes with 75 tests
- Verified: `mix brock.cards.coverage` still reports the current fixed-deck registry coverage successfully

## [2026-05-29] implementation | Deck Macro Foundation
- Added: `Brock.Tcg.Sim.Decklist` macro for generated/static deck modules with compile-time source identity and 60-card validation
- Updated: Dragapult 27431 and Alakazam/Dudunsparce 27147 deck modules to use the macro while preserving `source_url/0`, `counts/0`, and `card_ids/0`
- Verified: `mix test test/brock/tcg/sim` passes with 75 tests
- Verified: `mix brock.cards.coverage` still reports both fixed decks as 60 cards with no unsupported IDs
- Verified: `mix precommit` passes with 80 tests

## [2026-05-29] implementation | Current Registry Coverage Report
- Added: `mix brock.cards.coverage` Phase 0 report for the current hand-written TCG registry and two fixed Limitless deck modules
- Verified: `mix brock.cards.coverage` reports 44 fixed-deck cards, legacy-registry metadata coverage, implemented behavior coverage, and generic-damage-only attack coverage
- Verified: `mix test test/brock/tcg/sim` passes with 75 tests
- Verified: `mix precommit` passes with 80 tests

## [2026-05-29] planning | Meta Deck, TCGdex, Card DSL, and LiveView Play North Star
- Added: North-star implementation plan for metadata-backed meta deck support, behavior DSL overlays, hook migration, coverage, pairwise smoke tests, and basic LiveView hotseat play
- Updated: Engine index with north-star entry

## [2026-05-28] research | Cross-Platform TCG Client Architecture
- Added: Raw React web/RN renderer research
- Added: Raw embedded Godot web/Android/iOS research
- Added: Raw Godot card repository validation
- Added: Engine synthesis for React web/RN app shell plus embedded Godot gameplay renderer
- Updated: Engine index and renderer-options cross-link

## [2026-05-28] research | TCG Client Renderer Options
- Added: Raw AI-thread capture with cited renderer/client sources
- Added: Engine synthesis for React/R3F, React Native, Godot 3D, and Godot 2D client options
- Updated: Engine index with TCG client renderer options entry

## [2026-05-28] implementation | Full-Game Two-Deck Simulator Implementation
- Added: State-machine-first simulator implementation note
- Added: Undo/redo snapshot requirement and current implementation shape
- Added: Setup Bench selection, Prize placement, and card accounting invariant notes
- Added: Turn handoff, attack damage, KO, Prize, and winner flow notes
- Added: Scripted playthrough milestone covering replacement Active, final Prize, deck-out, no-Pokémon, and concession win paths
- Added: Attack metadata, attack-cost validation, and pending attack resolution notes
- Added: Normal Evolution from hand, evolution-stack accounting, and evolution undo notes
- Added: Scripted Trainer/Stadium/Tool/search/discard movement and multi-scenario end-to-end coverage notes
- Added: Card-specific Rare Candy, Buddy-Buddy Poffin, Ultra Ball, Boss's Orders, Crushing Hammer, and Enhanced Hammer notes
- Added: Retreat, switch, first-turn Evolution lock, and same-turn Evolution restriction notes
- Added: Verified Drakloak, Kadabra, Alakazam, Dudunsparce ability slice notes
- Added: Verified Abra, Dunsparce, Alakazam, and Dragapult ex attack/effect notes
- Added: Verified Lillie's Determination, Crispin, and Night Stretcher Supporter/Item effect notes
- Added: Verified Unfair Stamp KO-last-turn eligibility and shuffle/draw notes
- Added: Verified Poké Pad, Dawn, and Sacred Ash Trainer effect notes
- Added: Verified Judge, Hilda, and Lana's Aid Supporter effect notes
- Added: Verified Air Balloon retreat-cost reduction note
- Added: Verified Team Rocket's Watchtower Colorless Ability lock note
- Added: Verified Forest of Vitality same-turn Grass Evolution note
- Added: Verified Rellor Slight Intrusion self-damage attack note
- Added: Verified Risky Ruins Basic non-Dark Bench damage note
- Added: Verified Handheld Fan attack-triggered Energy movement note
- Added: Verified Rabsca Spherical Shield bench protection note
- Added: Verified Budew Itchy Pollen next-turn Item lock note
- Added: Verified Moltres Fighting Wings Pokémon ex damage bonus note
- Added: Verified Munkidori Adrena-Brain and Mind Bend notes
- Added: Verified Fezandipiti ex Flip the Script and Cruel Arrow notes
- Updated: Engine index with full-game two-deck simulator implementation entry

## [2026-05-27] research | Card Engine Authoring Models
- Added: Engine section to index
- Added: Card Engine Authoring Models
- Updated: Captured Elixir macro DSL as a possible alternative to TypeScript-style generated source stubs

## [2026-05-26] ingest | PTCGL Match Data Sources
- Updated: PTCGL Battle Log Observability
- Updated: Pokémon TCG Coach MVP

## [2026-05-26] ingest | Card and Tournament Data Sources
- Updated: Pokémon TCG Coach MVP

## [2026-05-26] ingest | Pokémon TCG Competitive Resource Map
- Updated: Pokémon TCG Coach MVP

## [2026-05-26] ingest | Post-Game Review Patterns
- Updated: Pokémon TCG Coach MVP

## [2026-05-26] ingest | Companion and Session-Loop Patterns
- Updated: Post-Game Review Patterns
- Updated: Pokémon TCG Coach MVP

## [2026-05-26] ingest | Integration Risk and Access Notes
- Updated: Card and Tournament Data Sources
- Updated: Pokémon TCG Coach MVP

## [2026-05-26] ingest | First Coaching-Rule Taxonomy
- Updated: Pokémon TCG Coach MVP

## [2026-05-26] ingest | Pokémon TCG Practice Tool Surface
- Updated: Pokémon TCG Competitive Resource Map

## [2026-05-26] ingest | Learning-Science Patterns for Practice Tools
- Updated: Companion and Session-Loop Patterns

## [2026-05-26] ingest | Pokémon TCG Practice Idea Bank

## [2026-05-26] ingest | Drill and Microtraining Patterns
- Updated: Pokémon TCG Practice Tool Surface
- Updated: Pokémon TCG Practice Idea Bank

## [2026-05-26] ingest | Pokémon TCG Practice Tool Surface
- Updated: Pokémon TCG Practice Idea Bank
