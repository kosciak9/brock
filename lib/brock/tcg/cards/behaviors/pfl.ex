defmodule Brock.Tcg.Cards.Behaviors.PFL do
  @moduledoc false

  use Brock.Tcg.Cards.DSL

  card "PFL-083" do
    attack(:run_around, effect: %{type: :switch_self_with_bench})
    attack(:kick, effect: nil)
  end

  card "PFL-085" do
    card_effect(effect: %{type: :prevent_damage_counters_to_bench_from_opponent_pokemon_effects})
  end
end
