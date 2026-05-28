# TCG client renderer AI thread

- Source: https://chatgpt.com/share/6a185323-24d4-832f-b0d9-2cc403c6cf39
- Local export: ../../../renderer-thread.html
- Collected: 2026-05-28
- Published: 2026-05-28
- Type: AI conversation export with cited sources
- Verification note: The source links and excerpts below are captured from the exported thread. External claims should be treated as research leads until the linked repositories/docs are inspected directly.

## Thread focus

The thread explores renderer/client options for a Pokémon-like TCG where the authoritative game server already exists. The client is assumed to be visualization, local interaction, animation, and command/event sending only.

## Source links cited by the thread

### React / Three.js / web and native renderer leads

- https://github.com/colyseus/turnbased-cards-demo
  - Cited as the best initial architecture reference for separate authoritative game state and multiple renderer clients.
- https://github.com/TesseractCat/bg3d
  - Cited for tabletop interaction patterns: orbit/pan/zoom, object dragging, cards/decks/hands, lobbies, and asset packs.
- https://github.com/keeshii/ryuu-play
  - Cited as a Pokémon-specific TypeScript TCG simulator with shared logic, server, web client, and Android wrapper.
- https://github.com/simeydotme/pokemon-cards-css
  - Cited as a visual-polish reference for Pokémon-like holo/foil/tilt effects.
- https://github.com/thatsprettyfaroutman/markdown-threejs-cards
  - Cited for React Three Fiber card surfaces and generated card-face content via Offscreen Canvas / Web Workers.
- https://github.com/pmndrs/react-three-fiber
  - Cited as the core React renderer for Three.js, including React DOM and React Native support.
- https://github.com/expo/expo-three
  - Cited as a bridge from Three.js to Expo GL / React Native.
- https://github.com/margelo/react-native-filament
  - Cited as a native 3D renderer option for React Native worth watching.

### Godot docs cited by the thread

- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html
- https://docs.godotengine.org/en/latest/tutorials/export/exporting_for_web.html
- https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- https://docs.godotengine.org/en/4.4/tutorials/rendering/renderers.html
- https://docs.godotengine.org/en/4.5/classes/class_websocketpeer.html
- https://docs.godotengine.org/en/stable/tutorials/networking/websocket.html
- https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
- https://docs.godotengine.org/cs/4.x/tutorials/export/exporting_for_web.html

### Godot card/game repository leads

- https://github.com/rametta/Pali
  - Cited as the closest 3D Godot TCG match: GDScript, Godot 4, multiplayer, and reusable as a base/reference.
- https://github.com/db0/godot-card-game-framework
  - Cited as an established Godot card-game framework with prepared scenes/classes and a rules scripting engine.
- https://github.com/db0/godot-card-game-framework/issues/178
  - Cited as evidence that the framework may be Godot 3-era / Godot 4 migration is uncertain.
- https://github.com/chun92/card-framework
  - Cited as a modern Godot 4.x 2D card-game addon for TCG/deckbuilder/Solitaire-style interactions.
- https://github.com/BananaHolograma/Veneno
  - Cited as a Godot 4 playing-card demo with interaction and animation ideas.
- https://github.com/insideout-andrew/deckbuilder-framework
  - Cited for basic deck/card mechanics such as draw, shuffle, and standard interactions.
- https://github.com/hackclub/hackstone
  - Cited as an online card game in Godot, probably useful for multiplayer UX ideas.
- https://github.com/kiinii-pixel/Card-Wars
  - Cited as a TCG-like Godot project targeting PC/browser friendliness.
- https://github.com/topics/multiplayer-game?l=gdscript&o=desc&s=forks&utf8=%E2%9C%93
  - Cited as metadata/context for small GDScript multiplayer-game repositories.
- https://github.com/topics/ai-game-development
  - Cited in relation to `beralee/PtcgDeckAgent`; the thread did not provide a direct repository citation for that project.

## Extracted excerpts and claims

### Existing-server framing

The thread narrows the problem once the server already exists:

```text
server state snapshot/event stream
        ↓
client projection / animation state
        ↓
3D scene
        ↓
pointer gesture → command/event → server
```

It reframes the client as needing patterns for rendering a board/table, rendering many cards cheaply, selecting/dragging/hovering/tapping cards, and converting UI actions into server events.

### Renderer state separation

The thread recommends not letting React or Godot view state directly equal server state:

```text
serverState      canonical truth
viewState        currently animated/selected/hovered state
pendingActions   optimistic or waiting-for-server actions
```

This avoids coupling local animation, hover, selection, and pending-command affordances to the canonical authoritative game state.

### Renderer-agnostic command/render model

The thread proposes a thin contract shape:

```ts
type GameCommand =
  | { type: "play_card"; cardId: string; targetZoneId: string }
  | { type: "attach_energy"; cardId: string; targetPokemonId: string }
  | { type: "attack"; attackerId: string; attackId: string }
  | { type: "pass" }

type RenderCard = {
  id: string
  imageUrl: string
  zone: "hand" | "active" | "bench" | "discard" | "prizes"
  position: [number, number, number]
  rotation: [number, number, number]
  selectable: boolean
  legalActions: GameCommand[]
}
```

The renderer’s job is then to render cards, handle hover/drag/tap, show legal targets, emit commands, and animate server-confirmed results.

### React/R3F packaging idea

For a web-first renderer, the suggested package split is:

```text
packages/
  game-client-protocol/   # websocket/events/types
  game-view-model/        # converts server state → render model
  renderer-r3f-web/       # React Three Fiber
  renderer-native-spike/  # later: RN R3F or Filament
```

### Godot as a thin client

The Godot framing mirrors the same architecture:

```text
server snapshot/events
        ↓
Godot client projection
        ↓
3D board/cards/animations
        ↓
tap/drag/select → command → server
```

The thread recommends GDScript over C# for this use case, because the client is visualization, input, animation, networking, and state projection rather than authoritative rules execution.

### Godot project shape

Suggested Godot structure:

```text
Godot project
  scenes/
    GameTable.tscn
    Card3D.tscn
    HandView.tscn
    ZoneView.tscn
    ActionMenu.tscn

  scripts/
    network/
      GameSocket.gd
      Protocol.gd

    state/
      GameStore.gd
      ViewModelBuilder.gd

    input/
      CardPicker.gd
      DragController.gd

    views/
      Card3D.gd
      HandView.gd
      ZoneView.gd
```

Key split:

```text
GameStore.gd
  receives server snapshots/events
  keeps canonical client-side copy

ViewModelBuilder.gd
  converts game state into positions/visibility/highlights

Card3D.gd / HandView.gd / ZoneView.gd
  only render + animate
```

### Godot platform status claims

The thread claims Godot + GDScript can target web, iOS, and Android, with Android/iOS native as good targets and web as constrained/secondary. It highlights:

- Android native export is a normal Godot path.
- iOS export requires macOS + Xcode for signing/building.
- Web export depends on WebAssembly and WebGL 2.0.
- Native mobile exports should perform significantly better than mobile web exports.
- Godot web exports using threads may need COOP/COEP cross-origin isolation headers:

```http
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Embedder-Policy: require-corp
```

### Godot TCG concept mapping

The thread maps TCG renderer concepts onto Godot primitives:

| TCG concept | Godot concept |
| --- | --- |
| Board / mat | `Node3D` scene |
| Cards | `MeshInstance3D` planes with card textures |
| Hand | parent `Node3D` with curved/card-fan layout |
| Active / bench / prize zones | fixed transform anchors |
| Selection / legal targets | materials, outlines, decals, particles |
| Drag / tap | input events + ray-casting |
| Animations | `Tween`, `AnimationPlayer`, scene transitions |

### 2D with depth

The final recommendation shifts toward 2D if touch quality and animation matter more than spatial realism:

```text
board mat
cards as 2D nodes
smooth fan hand
drag/tap/select
zoomed card preview
animated movement between zones
particles/highlights
small screen adaptive layout
```

Godot 2D primitive mapping:

```text
Control / CanvasLayer  → UI
Node2D                 → cards, board, animations
Tween                  → movement/scale/rotation
AnimationPlayer        → reusable card animations
Area2D                 → hit detection
TextureRect/Sprite2D   → card art
```

### Touch-first interaction model

The thread recommends avoiding drag-everything as the primary mobile interaction:

```text
tap card
→ show legal actions / legal targets
→ tap target
→ send command
→ animate result after server confirmation
```

Dragging can remain as secondary sugar:

```text
drag card onto valid target
→ snap/highlight target
→ release sends same command
```

### Final recommendation from the thread

The thread’s final recommendation:

```text
Godot 2D + GDScript
native iOS/Android as first-class
web as supported secondary target
server-authoritative protocol
touch-first command UI
```

Rationale: a polished 2D client may feel better than mediocre 3D on touch; Pokémon TCG Live itself is closer to 2.5D UI than a true 3D tabletop.
