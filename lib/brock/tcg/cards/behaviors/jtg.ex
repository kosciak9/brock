defmodule Brock.Tcg.Cards.Behaviors.JTG do
  @moduledoc false

  use Brock.Tcg.Cards.DSL

  card "JTG-143" do
    card_effect(
      effect: %{
        type: :turn_bonus_attack_damage_to_opponent_active_pokemon_ex,
        bonus_damage: 40
      }
    )
  end
end
