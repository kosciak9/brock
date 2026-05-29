defmodule Brock.Tcg.Cards.Behaviors.SSP do
  @moduledoc false

  use Brock.Tcg.Cards.DSL

  card "SSP-111" do
    attack(:coordinated_throwing,
      damage: 0,
      effect: %{type: :damage_per_own_basic_pokemon_in_play, damage_per_pokemon: 20}
    )
  end

  card "SSP-170" do
    card_effect(effect: %{type: :search_pokemon_ex_to_hand, max_targets: 3})
  end
end
