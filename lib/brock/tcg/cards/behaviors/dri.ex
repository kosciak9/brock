defmodule Brock.Tcg.Cards.Behaviors.DRI do
  @moduledoc false

  use Brock.Tcg.Cards.DSL

  card "DRI-010" do
    ability(:flower_curtain,
      effect: %{type: :prevent_attack_damage_to_non_rule_box_bench}
    )

    attack(:smash_kick, effect: nil)
  end

  card "DRI-019" do
    attack(:take_down, effect: %{type: :self_damage, damage: 10})
  end

  card "DRI-177" do
    card_effect(effect: %{type: :search_basic_team_rocket_pokemon_to_hand, max_targets: 3})
  end

  card "DRI-178" do
    card_effect(effect: %{type: :search_team_rocket_supporter_to_hand})
  end
end
