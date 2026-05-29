# Wiki Log

## [2026-05-29] implementation | Psyduck Plain-Damage Attack Behavior
- Added: Psyduck `ASC-039` now has ASC DSL manifest entries for `Damp` and `Ram`, and the registry overlay marks `Ram` as explicit exact plain-damage behavior instead of generic damage
- Preserved: cached TCGdex metadata remains the source of truth for static Pokémon metadata, Ability text, attack cost, and damage; the `Ram 20` attack text was cross-checked against Limitless before coding
- Updated: `mix brock.cards.coverage` now reports one fewer `generic_damage_only` behavior family across Alakazam/Dudunsparce 27147, Festival Lead 27445, and Lopunny Dudunsparce 27514
- Verified: focused manifest/registry smoke check, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Shaymin Bench-Protection Ability Behavior
- Added: Shaymin `DRI-010` now has a DSL Ability/attack manifest entry and registry overlays for `Flower Curtain` and `Smash Kick`, mapping `Flower Curtain` to a `:before_damage` hook that prevents attack damage to the player's non-rule-box Benched Pokémon while allowing damage-counter effects to continue
- Preserved: static Pokémon metadata, Ability text, attack cost, and damage continue to come from the committed TCGdex cache; the Ability text was cross-checked against Limitless before coding
- Updated: `mix brock.cards.coverage` now reports Shaymin as implemented for Festival Lead 27445, reducing imported-deck `behavior_missing` card count by one and imported-deck `generic_damage_only` family count by one
- Verified: focused manifest/registry/hook smoke checks, `mix brock.cards.coverage`, and `mix test test/brock/tcg/sim` pass

## [2026-05-29] implementation | TWM Applin Search Attack Behavior
- Added: Applin `TWM-126` now has DSL attack manifest entries and registry overlays for `Find a Friend` and `Rolling Tackle`, mapping `Find a Friend` to an executable deck Pokémon search-to-hand attack primitive and marking `Rolling Tackle` as exact plain-damage behavior while keeping static cost, damage, and printed text in the TCGdex cache
- Preserved: cached TCGdex metadata remains the source of truth, and the attack text was cross-checked against Limitless before coding
- Updated: `mix brock.cards.coverage` now reports `TWM-126` as implemented for Festival Lead 27445, reducing imported-deck `behavior_missing` card count by one and imported-deck `generic_damage_only` family count by one
- Verified: focused manifest/registry/engine smoke check, `mix brock.cards.coverage`, and `mix test test/brock/tcg/sim` pass

## [2026-05-29] implementation | Buneary Switch Attack Behavior
- Added: Buneary `PFL-083` now has a DSL attack manifest entry and registry overlays for `Run Around` and `Kick`, mapping the switch attack to the existing `:switch_self_with_bench` primitive and marking `Kick` as exact plain-damage behavior while keeping cost, damage, and static facts in the TCGdex cache
- Preserved: cached TCGdex metadata remains the source of truth, and the attack text was cross-checked against Limitless before coding
- Updated: `mix brock.cards.coverage` now reports Buneary as implemented for Lopunny Dudunsparce 27514, reducing imported-deck `behavior_missing` card count by one
- Verified: focused manifest/registry smoke check, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | SCR Applin Plain-Damage Attack Behavior
- Added: Applin `SCR-012` now has a DSL attack manifest entry and registry overlay for `Spray Fluid`, explicitly marking the attack as exact plain-damage behavior while keeping cost, damage, and static facts in the TCGdex cache
- Preserved: cached TCGdex metadata remains the source of truth, and the attack text was cross-checked against Limitless before coding
- Updated: `mix brock.cards.coverage` now reports `SCR-012` as implemented for Festival Lead 27445, reducing imported-deck `generic_damage_only` card count by one
- Verified: focused manifest/registry smoke check, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Grookey Plain-Damage Attack Behavior
- Added: Grookey `TWM-014` now has DSL attack manifest entries and registry overlays for `Smash Kick` and `Branch Poke`, explicitly marking both attacks as exact plain-damage behavior while keeping cost, damage, and static facts in the TCGdex cache
- Preserved: cached TCGdex metadata remains the source of truth, and the attack text was cross-checked against Limitless before coding
- Updated: `mix brock.cards.coverage` now reports Grookey as implemented for Festival Lead 27445, reducing imported-deck `generic_damage_only` card count by one
- Verified: focused manifest/registry smoke checks, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Kieran Supporter Behavior
- Added: Kieran `TWM-154` now has a DSL card-effect manifest entry and executable Supporter reducer choices for switching the player's Active Pokémon with a Benched Pokémon or granting +30 attack damage to the opponent's Active Pokémon ex/V for the turn
- Preserved: static Supporter text and metadata continue to come from the committed TCGdex cache; the card text was cross-checked against Limitless before coding
- Updated: `mix brock.cards.coverage` now reports Kieran as implemented for Festival Lead 27445, reducing imported-deck `behavior_missing` card count by one
- Verified: focused reducer/hook smoke check, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Black Belt's Training Supporter Behavior
- Added: Black Belt's Training `JTG-143` now has a DSL card-effect manifest entry and an executable Supporter reducer action that marks the player's turn for +40 attack damage to the opponent's Active Pokémon ex
- Preserved: static Supporter text and metadata continue to come from the committed TCGdex cache; the card text was cross-checked against Limitless before coding
- Updated: `mix brock.cards.coverage` now reports Black Belt's Training as implemented for Festival Lead 27445, reducing imported-deck `behavior_missing` card count by one
- Verified: focused damage-modifier smoke check, `mix brock.cards.coverage`, and `mix test test/brock/tcg/sim` pass

## [2026-05-29] implementation | Lucky Helmet Tool Behavior
- Added: Lucky Helmet `TWM-158` now has a DSL card-effect manifest entry and an executable `:after_damage` hook that draws 2 cards when the attached Active Pokémon is damaged by an opponent's attack
- Preserved: static Tool text and metadata continue to come from the committed TCGdex cache; the registry overlay declares only executable behavior
- Updated: `mix brock.cards.coverage` now reports Lucky Helmet as implemented for Rocket's Mewtwo 27459, reducing imported-deck `behavior_missing` card count by one
- Verified: focused hook smoke check, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Wally's Compassion Supporter Behavior
- Added: Wally's Compassion `MEG-132` now has a DSL card-effect manifest entry and an executable reducer action that heals all damage from a chosen Mega Evolution Pokémon ex and, when damage was healed, returns attached Energy to hand
- Preserved: target and attached-Energy eligibility use cached TCGdex static facts, while exact Supporter text was checked against the committed cache and Limitless
- Updated: `mix brock.cards.coverage` now reports Wally's Compassion as implemented for Lopunny Dudunsparce 27514, reducing imported-deck `behavior_missing` card count by one
- Verified: focused reducer smoke check, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Cyrano Supporter Behavior
- Added: Cyrano `SSP-170` now has a DSL card-effect manifest entry and an executable reducer action that searches up to three chosen Pokémon ex from the player's deck and puts them into hand
- Preserved: target eligibility uses cached TCGdex static facts and the registry overlay declares only executable behavior, while exact card text was checked against the committed cache and Limitless
- Updated: `mix brock.cards.coverage` now reports Cyrano as implemented for Raging Bolt Ogerpon 27599, reducing imported-deck `behavior_missing` card count by one
- Verified: targeted registry test, Cyrano reducer smoke check, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Ciphermaniac's Codebreaking Supporter Behavior
- Added: Ciphermaniac's Codebreaking `TEF-145` now has a DSL card-effect manifest entry and an executable reducer action that searches two chosen deck cards and places them on top in the chosen order
- Preserved: static Supporter text and metadata continue to come from the committed TCGdex cache; the registry overlay only declares executable behavior
- Updated: `mix brock.cards.coverage` now reports Ciphermaniac's Codebreaking as implemented for Raging Bolt Ogerpon 27599, reducing imported-deck `behavior_missing` card count by one
- Verified: focused reducer smoke check, targeted registry test, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Team Rocket's Transceiver Item Behavior
- Added: Team Rocket's Transceiver `DRI-178` now has a DSL card-effect manifest entry and an executable reducer action that can reveal a Supporter with "Team Rocket" in its name from the player's deck and put it into hand
- Preserved: target eligibility uses cached TCGdex static facts, so the search can find metadata-cached Team Rocket Supporters before those Supporters have executable behavior overlays
- Updated: `mix brock.cards.coverage` now reports Team Rocket's Transceiver as implemented for Rocket's Mewtwo 27459, reducing imported-deck `behavior_missing` card count by one
- Verified: focused reducer smoke check, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Bug Catching Set Item Behavior
- Added: Bug Catching Set `TWM-143` now has a DSL card-effect manifest entry and an executable reducer action that can reveal up to two valid cards from the top 7 cards of the player's deck and put them into hand
- Preserved: target eligibility uses cached TCGdex static facts for `{G}` Pokémon and Basic `{G}` Energy, so the search can find metadata-cached imported-deck cards before those cards have executable behavior overlays
- Updated: `mix brock.cards.coverage` now reports Bug Catching Set as implemented for Festival Lead 27445 and Rocket's Mewtwo 27459, reducing imported-deck `behavior_missing` card count by one
- Verified: focused reducer smoke check, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Pokégear 3.0 Item Behavior
- Added: Pokégear 3.0 `SVI-186` now has a DSL card-effect manifest entry and an executable reducer action that can reveal a Supporter from the top 7 cards of the player's deck and put it into hand
- Updated: `mix brock.cards.coverage` now reports Pokégear 3.0 as implemented for Lopunny Dudunsparce 27514, reducing imported-deck `behavior_missing` card count by one
- Verified: focused reducer smoke check, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Imported Basic Energy Registry Support
- Added: all deck-pool Basic Energy IDs now resolve through metadata-only registry overlays, including imported-deck Grass, Water, Lightning, and Fighting Energy
- Preserved: static Energy names/types continue to come from the committed TCGdex cache, with provided Energy types inferred by the existing registry facade
- Verified: targeted registry test, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Energy Switch Item Behavior
- Added: Energy Switch `MEG-115` now has a DSL card-effect manifest entry and an executable reducer action that moves a Basic Energy from one of the player's Pokémon to another
- Updated: `mix brock.cards.coverage` now reports Energy Switch as implemented across Raging Bolt Ogerpon 27599 and Rocket's Mewtwo 27459
- Verified: focused reducer smoke check, targeted registry test, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | All-Deck Coverage Report
- Added: `mix brock.cards.coverage` now reports all six known deck modules from the TCGdex deck pool instead of only the two fixed supported decks
- Added: coverage rows now include all 101 cached known-deck cards, with imported cards falling back to cached metadata and surfacing `behavior_missing` or `generic_damage_only` status when no registry overlay exists
- Verified: `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Rabsca Psychic Variable-Damage Attack
- Added: Rabsca `Psychic` now has an executable variable-damage overlay for `10 + 30` damage per Energy attached to the opponent's Active Pokémon
- Added: `Brock.Tcg.Cards.Behaviors.TEF` manifest coverage for Rabsca `Spherical Shield` and `Psychic` without adding static card metadata to the DSL
- Verified: targeted registry test, runtime reducer smoke check, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Handheld Fan After-Damage Hook
- Added: `Brock.Tcg.Sim.Hooks` now handles Handheld Fan `TWM-150` attack-triggered Energy movement through the `:after_damage` phase
- Migrated: declared attack resolution now routes post-damage hook checks through `Brock.Tcg.Sim.Hooks` instead of using the engine-local Handheld Fan helper
- Verified: targeted Handheld Fan scenario, `mix test test/brock/tcg/sim`, `mix brock.cards.coverage`, and `mix precommit` pass

## [2026-05-29] implementation | Rabsca Before-Damage Hook
- Added: `Brock.Tcg.Sim.Hooks` now handles Rabsca `Spherical Shield` opponent attack-effect bench damage prevention through the `:before_damage` phase
- Migrated: Phantom Dive bench damage now routes through the hook path instead of using a Rabsca-specific engine helper
- Verified: targeted Rabsca scenario, `mix test test/brock/tcg/sim`, `mix brock.cards.coverage`, and `mix precommit` pass

## [2026-05-29] implementation | Team Rocket's Watchtower Before-Ability Hook
- Added: `Brock.Tcg.Sim.Hooks` now handles Team Rocket's Watchtower Colorless Pokémon Ability prevention through the `:before_ability` phase
- Migrated: Ability lookup now runs hook checks before resolving executable Ability behavior, removing the Watchtower-specific reducer check from `Brock.Tcg.Sim.Engine`
- Verified: targeted Watchtower scenario, `mix test test/brock/tcg/sim`, `mix brock.cards.coverage`, and `mix precommit` pass

## [2026-05-29] implementation | Budew Item-Lock Before-Play-Trainer Hook
- Added: `Brock.Tcg.Sim.Hooks` now handles Item-card prevention for players marked by Budew `Itchy Pollen` through the `:before_play_trainer` phase
- Migrated: Item lock checks in trainer reducers now call the hook path instead of reading `item_cards_locked?` directly in the engine helper
- Verified: targeted Budew scenario, `mix test test/brock/tcg/sim`, `mix brock.cards.coverage`, and `mix precommit` pass

## [2026-05-29] implementation | ACE Nullifier Before-Play-Trainer Hook
- Added: `Brock.Tcg.Sim.Hooks` as the first hook phase runner with `:before_play_trainer` returning `{:ok, state}` or `{:halt, reason}`
- Migrated: Genesect `ACE Nullifier` ACE SPEC prevention now runs through the hook path instead of an engine-local reducer-specific check
- Verified: targeted ACE Nullifier scenario, `mix test test/brock/tcg/sim`, `mix brock.cards.coverage`, and `mix precommit` pass

## [2026-05-29] implementation | Special Energy Card-Effect DSL Manifest Entry
- Added: Telepathic Psychic Energy `POR-088` to `Brock.Tcg.Cards.Behaviors.POR` as the first representative Special Energy card-effect behavior manifest entry
- Preserved: cached TCGdex Energy type and raw effect remain the static source of truth; the DSL entry only declares the executable attach/search overlay
- Verified: manifest check with `MIX_ENV=test mix run --no-start -e ...`, `mix test test/brock/tcg/cards/metadata_test.exs test/brock/tcg/sim/card_registry_test.exs`, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Stadium Card-Effect DSL Manifest Entry
- Added: Forest of Vitality `MEG-117` to `Brock.Tcg.Cards.Behaviors.MEG` as the first representative Stadium card-effect behavior manifest entry
- Preserved: cached TCGdex Stadium type and raw effect remain the static source of truth; the DSL entry only declares the executable same-turn Grass Evolution exception overlay
- Verified: manifest check with `MIX_ENV=test mix run --no-start -e ...`, `mix test test/brock/tcg/cards/metadata_test.exs test/brock/tcg/sim/card_registry_test.exs`, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Tool Card-Effect DSL Manifest Entry
- Added: Air Balloon `ASC-181` to `Brock.Tcg.Cards.Behaviors.ASC` as the first representative Tool card-effect behavior manifest entry
- Preserved: cached TCGdex Tool type and raw effect remain the static source of truth; the DSL entry only declares the executable retreat-cost reduction overlay
- Verified: manifest check with `MIX_ENV=test mix run --no-start -e ...`, `mix test test/brock/tcg/cards/metadata_test.exs test/brock/tcg/sim/card_registry_test.exs`, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Supporter Card-Effect DSL Manifest Entry
- Added: Lana's Aid `TWM-155` to `Brock.Tcg.Cards.Behaviors.TWM` as the first representative Supporter card-effect behavior manifest entry
- Preserved: cached TCGdex Supporter type and raw effect remain the static source of truth; the DSL entry only declares the executable discard-recovery overlay
- Verified: manifest check with `MIX_ENV=test mix run --no-start -e ...`, `mix test test/brock/tcg/cards/metadata_test.exs test/brock/tcg/sim/card_registry_test.exs`, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

## [2026-05-29] implementation | Item Card-Effect DSL Manifest Entry
- Added: Unfair Stamp `TWM-165` to `Brock.Tcg.Cards.Behaviors.TWM` as the first representative Item card-effect behavior manifest entry
- Preserved: cached TCGdex Trainer type, ACE SPEC rarity, and raw effect remain the static source of truth; the DSL entry only declares the executable KO-eligibility shuffle/draw overlay
- Verified: manifest check with `MIX_ENV=test mix run --no-start -e ...`, `mix test test/brock/tcg/cards/metadata_test.exs test/brock/tcg/sim/card_registry_test.exs`, `mix brock.cards.coverage`, `mix test test/brock/tcg/sim`, and `mix precommit` pass

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
