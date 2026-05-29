# Meta Deck, TCGdex, Card DSL, and LiveView Play North Star

Updated: 2026-05-29

## Scope

This is the north-star implementation plan for moving the Pokémon TCG simulator from two fixed decklists to a maintainable meta-deck platform.

Goals:

- Add four more meta decks from Limitless: Raging Bolt Ogerpon 27599, Festival Lead 27445, Lopunny Dudunsparce 27514, and Rocket's Mewtwo 27459.
- Support all cards needed by those decks and allow any supported deck to play any other supported deck.
- Use TCGdex API/cache as the source for static card metadata: name, type/category, HP, stage, retreat, weakness/resistance when available and normalizable, trainer type, energy type, regulation/legality, images, and raw attack/ability/effect text.
- Do not hand-write static card metadata except temporary compatibility shims or explicit overrides for API gaps.
- Author only executable behavior: attacks, abilities, effects, timing hooks, special conditions, replacement/prevention effects, and exact rules interpretations.
- Add a later very basic Phoenix LiveView UI for two human players to play supported decks.

## Current baseline

- The current simulator is pure Elixir under `lib/brock/tcg/sim`.
- It supports Dragapult 27431 vs Alakazam/Dudunsparce 27147 end-to-end as scripted engine actions.
- The existing hand-written registry is the thing to replace or refactor behind a compatibility facade.
- There is no UI yet.

## Target supported deck pool

Existing supported decks:

- Dragapult 27431
- Alakazam/Dudunsparce 27147

New supported decks:

- Raging Bolt Ogerpon 27599
- Festival Lead 27445
- Lopunny Dudunsparce 27514
- Rocket's Mewtwo 27459

The target is pairwise support: any two supported deck modules can start a game, setup, play legal turns, and resolve supported card effects.

## Data and source-of-truth policy

- Brock card IDs remain public simulator IDs in `SET-localId` form, for example `TEF-123`.
- Limitless is the deck source and provides deck quantities plus `SET`/`localId` extracted from card links.
- TCGdex uses IDs like `sv05-123`; map Brock set abbreviations through TCGdex `set.abbreviation.official`.
- Store external source IDs, but keep Brock IDs as public simulator IDs.
- Commit the TCGdex cache and use it in normal tests.
- Network access is opt-in only; normal tests must not hit the network.
- Use `Req` for HTTP clients.

The key architectural decision is that TCGdex owns **static card facts** and Brock owns **executable semantics**.

TCGdex/cache should provide:

- card name;
- category/supertype;
- Pokémon type, HP, stage, suffix, retreat, raw weakness/resistance data where available;
- Trainer type;
- Energy type;
- regulation mark and legality;
- image and set identity;
- raw printed attack, Ability, and Trainer text.

Brock-authored behavior should provide:

- exact attack execution;
- exact Ability execution;
- Trainer/Tool/Stadium/Energy effects;
- timing hooks;
- prevention/replacement effects;
- exact targeting and hidden-information semantics;
- rulings, exceptions, and project-owned regression tests.

Agents should not copy TCGdex static fields into hand-written maps except as temporary compatibility shims or explicit overrides. If an override is needed, the coverage report should flag it with the reason and source.

Suggested cache layout:

- `priv/tcg/cards/tcgdex/sets.json`
- `priv/tcg/cards/tcgdex/cards/TEF-123.json`

## Metadata architecture

Candidate modules:

- `Brock.Tcg.Data.LimitlessDeck`
- `Brock.Tcg.Data.TCGdex`
- `Brock.Tcg.Cards.Metadata`
- `Brock.Tcg.Cards.Registry`

Metadata structs should be generated or normalized from cached TCGdex JSON. `CardRegistry.fetch/1` becomes a compatibility facade that combines the authored behavior overlay with metadata cache records.

Static fields come from the API/cache. Behavior DSL overlays executable fields only. Unsupported raw text should produce explicit unsupported behavior errors when reached, not silent no-ops.

Manual metadata overrides are allowed only for API gaps. Each override needs an explicit comment and should appear as a warning in coverage reports.

Recommended resolution order for `CardRegistry.fetch/1` during migration:

1. Load normalized metadata for the Brock card ID from cache.
2. Load behavior overlay for the same Brock card ID, if present.
3. Merge metadata plus behavior into the current engine-compatible shape.
4. If a requested attack, Ability, or effect has raw text but no behavior overlay, return an explicit unsupported-behavior error at action time.

This lets the project migrate without a rewrite. Existing cards can remain available while the internal source of static fields moves from the hand-written registry to TCGdex cache.

Compatibility rule: current simulator tests must stay green after every migration step. Do not replace the registry and DSL in one large change.

## Deck import pipeline

The Limitless scraper should fetch a deck page, extract card rows matching `/cards/{SET}/{localId}`, preserve quantity, name/archetype when possible, and validate that the total count is 60.

The TCGdex resolver should map set abbreviations to TCGdex set IDs and fetch all card data needed for imported decks.

Planned mix tasks:

```sh
mix brock.deck.import 27599
mix brock.deck.import 27599 --module RagingBolt27599
mix brock.deck.import 27599 --refresh
mix brock.cards.sync
mix brock.cards.coverage
mix brock.cards.check
```

Generated deck modules should be committed and use a deck macro with fields such as:

```elixir
deck id: "27599",
     name: "Raging Bolt Ogerpon",
     source_url: "https://limitlesstcg.com/decks/list/27599",
     counts: [...],
     card_ids: [...],
     validate: true
```

## Behavior DSL architecture

Important decision: the DSL must not hand-write static card data. Static metadata comes from the TCGdex cache. The DSL references card IDs and defines executable behavior only.

Desired shape:

```elixir
defmodule Brock.Tcg.Cards.Behaviors.TWM do
  use Brock.Tcg.Cards.DSL

  card "TWM-130" do
    attack :phantom_dive do
      deal_damage(200, :defending_active)
      place_damage_counters(:opponents_bench, total: 6)
    end
  end
end
```

The DSL may validate that referenced attacks and abilities exist in TCGdex metadata by name or generated slug. It should compile behavior overlay manifests keyed by Brock card ID and attack/ability IDs.

The DSL should produce coverage metadata and clear compile/runtime errors. Runtime errors should identify the card, behavior family, deck, and missing primitive or ruling where possible.

DSL responsibilities:

- reference a Brock card ID that already exists in metadata cache;
- bind behavior to printed attacks, Abilities, or play effects;
- validate that referenced names/slugs exist in the cached raw metadata;
- define executable behavior using primitives and hooks;
- emit a behavior manifest for coverage tooling;
- allow escape hatches for unusual cards, but make those escape hatches visible in coverage.

DSL non-responsibilities:

- storing HP, stage, type, retreat, card category, legality, or images;
- parsing natural-language card text into executable behavior;
- silently approximating a card whose exact effect is not implemented.

This is the preferred shape because it makes imported card data cheap while keeping exact gameplay semantics reviewable in code.

## Engine hook system

Hooks are needed to avoid brittle reducer-specific checks.

Candidate hook phases:

- `before_play_trainer`
- `before_ability`
- `before_attack_declared`
- `modify_damage`
- `before_damage`
- `after_damage`
- `after_knockout`
- `before_prize_choice`
- `after_prize_choice`
- `before_switch`
- `after_switch`
- `on_attach_energy`
- `on_attach_tool`
- `on_evolve`
- `on_end_turn`
- `on_pokemon_checkup`

Initial hook-sensitive migrations:

- Genesect ACE Nullifier
- Budew Itchy Pollen
- Team Rocket's Watchtower
- Rabsca Spherical Shield
- Handheld Fan

Hook returns should start with `{:ok, state}` and `{:halt, reason}`. Later additions can include prompts and effect additions.

## Behavior and effect primitives

The behavior layer needs primitives for:

- Search
- Draw
- Shuffle hand into deck
- Attach, move, and discard Energy
- Damage, damage counters, healing, prevention, and modification
- Switch, gust, and retreat
- Special conditions
- Prize flow
- Markers and usage limits

## Coverage model

Coverage statuses:

- `metadata_cached`
- `behavior_missing`
- `generic_damage_only`
- `implemented`
- `implemented_with_tests`
- `unsupported_effect`
- `needs_ruling`

Coverage is tracked per card and per behavior family. Supported decks cannot contain `behavior_missing` or `unsupported_effect` for reachable normal-play effects.

`mix brock.cards.coverage` should report card, decks, metadata status, behavior status, tests, and final status.

A deck is **supported** only when:

- it has exactly 60 cards;
- every card has cached metadata;
- every normally reachable attack, Ability, Trainer effect, Tool effect, Stadium effect, Energy effect, and rule-box interaction has behavior coverage;
- every unsupported or unresolved effect fails explicitly before it can corrupt state;
- representative tests exist for each unique behavior family in the deck;
- the deck passes setup and pairwise smoke tests against the supported deck pool.

Cards may exist as `metadata_cached` before their deck is supported. This is expected. Metadata import is not the same as playable support.

## Phased plan

### Phase 0: freeze baseline

- Keep Dragapult 27431 vs Alakazam/Dudunsparce 27147 green.
- Added `mix brock.cards.coverage` for the current registry: reports the two fixed decks, legacy-registry metadata status, behavior status, and generic-damage-only attack coverage.

### Phase 1: import decks and metadata

- Added a deck macro foundation for generated/static deck modules: source identity,
  names, quantities, `card_ids/0`, and compile-time 60-card validation now live in
  `Brock.Tcg.Sim.Decklist`.
- Imported Raging Bolt Ogerpon 27599 as a static deck module using the deck macro.
- Imported Festival Lead 27445 as a static deck module using the deck macro.
- Imported Lopunny Dudunsparce 27514 as a static deck module using the deck macro.
- Imported Rocket's Mewtwo 27459 as a static deck module using the deck macro.
- Added `Brock.Tcg.Data.TCGdex` plus opt-in `mix brock.cards.sync` network sync for cache generation.
- Cached TCGdex set metadata for the 15 deck-pool sets and card metadata for 101 unique cards across all six known deck modules under `priv/tcg/cards/tcgdex`.
- Keep importer/cache tests offline by default; tag network tests as `:external`.

### Phase 2: metadata-backed registry facade

- Added `Brock.Tcg.Cards.Metadata` to read normalized static facts from the committed TCGdex cache for representative Pokémon, Trainer, and Energy cards without changing engine behavior yet.
- Converted `CardRegistry.fetch/1` into a compatibility facade for the existing supported registry IDs.
- Static card data now comes from normalized cached TCGdex metadata in the facade, including raw printed attack, Ability, Trainer, and Energy text.
- Existing authored attack, Ability, and Energy behavior is overlaid onto the metadata-backed base.
- The old hand-written registry entries are now temporary behavior overlays plus explicit compatibility shims for current reducer gaps such as Brock-ID evolution links and weakness/resistance cache gaps.
- Added tests proving fetched registry metadata comes from cache for representative Pokémon, Trainer, and Energy cards, and that cached raw attack text without an executable overlay fails explicitly.
- Updated `mix brock.cards.coverage` to report `metadata_backed_registry` and `metadata_cached` for the 44 current fixed-deck cards.

### Phase 3: behavior DSL foundation

- Added initial `Brock.Tcg.Cards.DSL` executable-behavior manifest foundation.
- DSL `card` declarations now validate referenced card IDs and attack/Ability IDs against cached TCGdex metadata at compile time.
- Added first representative behavior manifest module, `Brock.Tcg.Cards.Behaviors.TWM`, declaring Dragapult ex `Phantom Dive` executable effect overlay without moving static facts out of the metadata cache.
- Ported Dragapult ex `Jet Headbutt` as the first representative plain-damage DSL manifest entry, relying on cached TCGdex damage/cost metadata without adding a static overlay.
- Ported Drakloak `Recon Directive` as the first representative Ability DSL manifest entry, relying on cached TCGdex Ability metadata and adding only the executable effect overlay.
- Ported Unfair Stamp as the first representative Item card-effect DSL manifest entry, relying on cached TCGdex Trainer metadata and adding only the executable shuffle/draw eligibility overlay.
- Ported Lana's Aid as the first representative Supporter card-effect DSL manifest entry, relying on cached TCGdex Trainer metadata and adding only the executable discard-recovery overlay.
- Ported Air Balloon as the first representative Tool card-effect DSL manifest entry, relying on cached TCGdex Trainer metadata and adding only the executable retreat-cost reduction overlay.
- Ported Forest of Vitality as the first representative Stadium card-effect DSL manifest entry, relying on cached TCGdex Trainer metadata and adding only the executable same-turn Grass Evolution exception overlay.
- Ported Telepathic Psychic Energy as the first representative Special Energy card-effect DSL manifest entry, relying on cached TCGdex Energy metadata and adding only the executable attach/search overlay.
- Port representative existing cards before broad migration.
- Start with cards that demonstrate different behavior families: plain damage, attack effect, Ability, Item, Supporter, Tool, Stadium, and Special Energy.

### Phase 4: effect primitives and hooks

- Added first hook runner, `Brock.Tcg.Sim.Hooks`, with a `:before_play_trainer` phase.
- Migrated Genesect `ACE Nullifier` ACE SPEC prevention out of the engine reducer-specific check and into the `:before_play_trainer` hook path while preserving existing reducer error behavior.
- Migrated Budew `Itchy Pollen` Item-card prevention into the `:before_play_trainer` hook path while preserving existing reducer error behavior.
- Migrated Team Rocket's Watchtower Colorless Ability prevention into the `:before_ability` hook path while preserving existing reducer error behavior.
- Migrated Rabsca `Spherical Shield` opponent attack-effect bench damage prevention into the `:before_damage` hook path while preserving the existing Phantom Dive prevention behavior.
- Migrated Handheld Fan attack-triggered Energy movement into the `:after_damage` hook path while preserving existing declared-attack resolution behavior.
- Add the first hook system.
- Migrate hook-sensitive current effects one by one.
- Avoid card-specific checks embedded in generic reducers.

### Phase 5: new meta-deck behavior families

- Implemented Rabsca `Psychic` as a variable-damage attack primitive and TEF DSL manifest entry, closing the remaining fixed-deck `behavior_missing` coverage gap before broader new-deck behavior-family work.
- Expanded `mix brock.cards.coverage` to report all six known deck modules and all 101 cached cards, exposing imported-deck `behavior_missing` and `generic_damage_only` gaps for Phase 5 prioritization.
- Implement missing behavior families for the four imported meta decks.
- Use coverage to divide work by behavior family and ruling risk.

### Phase 6: pairwise deck smoke tests

- Add pairwise smoke coverage across all six supported decks.
- Verify setup, legal turns, and supported effect resolution.

### Phase 7: basic Phoenix LiveView two-player UI

- Add a very basic human-vs-human UI for supported decks only.
- Keep it server-authoritative and backed by `Engine.apply_action/2`.
- Introduce a small action-command layer if needed so LiveView forms do not manually construct brittle nested action maps everywhere.

## Basic LiveView play UI phase

The first UI is for hotseat testing, not polish.

Constraints:

- Supported decks only.
- One LiveView process/session can own both players initially.
- No AI, matchmaking, or persistence required.
- Later work can split players into separate browser sessions.
- The UI must never bypass `Engine.apply_action/2`.
- The UI must preserve hidden information. A hotseat version may reveal both hands only if explicitly marked as a testing/dev mode.

Screen surfaces:

- Deck selection for player A/B
- Setup flow
- Hand, Active, Bench, discard count, and Prize count
- Action log
- Available scripted actions
- Pending choices: Prize choice, replacement Active, attack params, coin/confusion explicit choices

Implementation notes:

- Start with one LiveView and one in-memory game state per socket/session.
- Treat this as a manual test harness before making it a polished product surface.
- Render only enough information to make legal choices and inspect results.
- Use existing engine logs and invariants to surface state changes and bugs.
- Keep randomness explicit: coin flips and confusion checks are selected by the user or command layer, then passed into the engine.
- Do not introduce persistence, accounts, matchmaking, or AI in this phase.

Legal-action generation should be conservative. Initial action forms can be simple select-based controls.

Acceptance: two humans can play a supported-deck scripted game through the UI without IEx/tests.

## Agent work packages

- Limitless importer
- TCGdex adapter/cache
- Deck macro and generated deck modules
- Metadata-backed registry facade
- Behavior DSL prototype
- Hook system prototype
- Coverage report
- Meta-deck behavior implementation agents by behavior family
- Pairwise deck matrix tests
- Basic LiveView play UI

Agent workflow rules:

- Work in atomic slices.
- Prefer behavior-family implementation over one-off card hacks.
- Verify exact text from cached TCGdex plus official/Limitless references before coding behavior.
- Add or update coverage reports with every new deck/card behavior slice.
- Keep normal tests offline.
- Run `mix test test/brock/tcg/sim` and `mix precommit` for simulator-impacting changes.
- Use Conventional Commit messages and stage only intended files.

## Validation

- `mix test test/brock/tcg/sim`
- `mix brock.cards.coverage`
- `mix precommit`
- Importer/cache tests are offline by default.
- External/network tests are tagged `:external`.
- No normal test should depend on the network.

## Non-goals

- No full Standard card pool yet.
- No natural-language parser for card text.
- No AI opponent in this phase.
- No polished UI in the first LiveView phase.
- No live TCGdex dependency during normal tests.

## Definition of done

- Four new deck modules validate to 60.
- Six supported decks have cached metadata.
- Static card metadata comes from TCGdex cache, not hand-written maps.
- Behavior DSL overlays executable behavior.
- Coverage reports identify missing behavior, tests, and rulings.
- Any supported deck can play any other supported deck in pairwise smoke tests.
- Basic LiveView hotseat UI can play a supported match.
- `mix precommit` passes.

No deck should be called supported merely because its 60 card IDs import successfully. Import success means the deck is known. Supported means it is playable through exact implemented behavior for normal match play.

## Citations and URLs

Limitless deck sources:

- https://limitlesstcg.com/decks/list/27599
- https://limitlesstcg.com/decks/list/27445
- https://limitlesstcg.com/decks/list/27514
- https://limitlesstcg.com/decks/list/27459

TCGdex API references:

- https://api.tcgdex.net/v2/en/sets
- `https://api.tcgdex.net/v2/en/cards/{tcgdex-card-id}` such as `https://api.tcgdex.net/v2/en/cards/sv05-123`
