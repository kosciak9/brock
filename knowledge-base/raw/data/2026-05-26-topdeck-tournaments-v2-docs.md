# TopDeck.gg API – Tournaments V2

- Source: https://topdeck.gg/docs/tournaments-v2
- Collected: 2026-05-26
- Published: Unknown

## Excerpts

Page subtitle: "Tournaments · Players · Standings · Decklists · Free REST API"

Usage requirements:

- "The TopDeck.gg API is free to use"
- "Most endpoints allow 100 requests per minute"
- "Any project using the API must include a visible credit and link back to TopDeck.gg."

Authentication excerpt:

"All endpoints use the following base URL: https://topdeck.gg/api"

"Every request must include your API key in the `Authorization` header. Keys are free — create one from your account page."

Supported Pokémon formats listed in the docs:

- Standard
- Expanded
- Legacy
- GLC

Relevant endpoint excerpts:

- `POST /v2/tournaments` searches completed tournaments and returns standings, decklists, and optional round data
- `GET /v2/tournaments/{TID}` returns tournament metadata, standings, and rounds
- `GET /v2/tournaments/{TID}/standings` returns standings and decklists when available
- `GET /v2/tournaments/{TID}/players/{ID}` returns player details and match record
- `GET /v2/tournaments/{TID}/rounds` returns rounds, tables, and results

Conditional data notes from the docs:

- Decklists appear only after the event ends or when organizers allow them
- `deckObj` is present only when structured deck data is available
