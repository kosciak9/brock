# Pokémon TCG API docs

- Source: https://docs.pokemontcg.io ; https://docs.pokemontcg.io/getting-started/authentication ; https://docs.pokemontcg.io/getting-started/rate-limits
- Collected: 2026-05-26
- Published: Unknown

## Excerpts

Overview excerpt:

"The Pokémon TCG API is organized around REST. Our API has predictable resource-oriented URLs, accepts JSON encoded request bodies, returns JSON-encoded responses, and uses standard HTTP response codes, authentication, and verbs."

"You can use the Pokémon TCG API without registering for an API key, although your limits are far less than if you had an API key."

The docs navigation exposes card, set, type, subtype, supertype, and rarity endpoints, plus SDKs for Python, Ruby, Javascript, C#, Kotlin, Typescript, PHP, Go, Dart, and Elixir.

Authentication excerpt:

"The Pokémon TCG API uses API keys to authenticate requests. Sign up for an account at the Pokémon TCG Developer Portal to get your API key for free."

"Authentication to the API is performed via the `X-Api-Key` header."

"API requests without authentication won't fail, but your rate limits are drastically reduced."

Rate-limit excerpt:

"Third-party application rate limits depend on your API key. By default, requests are limited to 20,000/day."

"If you aren’t using an API key, you are rate limited to 1000 requests a day, and a maxium of 30 per minute."
