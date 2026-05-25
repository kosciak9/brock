# Pokémon TCG Battle Replay Parser

- Source: https://raw.githubusercontent.com/kagd/pokemon-tcg-battle-replay/master/README.md
- Collected: 2026-05-26
- Published: Unknown

## Excerpts

"A TypeScript-based tool that parses and analyzes Pokémon Trading Card Game Live battle logs, converting them into structured JSON data for analysis and replay purposes."

Features listed in the README:

- "Parses detailed battle logs from Pokémon TCG Live matches"
- "Converts battle data into structured JSON format"
- Tracks "Game setup and coin flip", "Player actions and card plays", "Attack damage and effects", "Prize card tracking", "Turn-by-turn progression", and "Game outcome and final score"

Input/output excerpts:

- "The tool accepts battle logs in text format and converts them into structured JSON data. Sample battle logs can be found in the `sampleBattleReplays` directory."
- "The parser generates two JSON files: `battle.json` ... `battle.battle-by-turn.json`"

Operational notes:

- Built with TypeScript
- Uses Azure OpenAI for advanced text processing
- TODO note: "Update parser to go turn by turn due to JSON truncation during output by AI model."
