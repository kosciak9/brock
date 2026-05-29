defmodule Brock.Tcg.Cards.Behaviors.TWM do
  @moduledoc false

  use Brock.Tcg.Cards.DSL

  card "TWM-129" do
    ability(:recon_directive,
      effect: %{type: :top_two_choose_one_to_hand_other_to_bottom}
    )
  end

  card "TWM-130" do
    attack(:jet_headbutt)

    attack(:phantom_dive,
      effect: %{type: :opponent_bench_damage_counters, total_counters: 6}
    )
  end

  card "TWM-165" do
    card_effect(
      effect: %{
        type: :shuffle_each_player_hand_into_deck_then_draw,
        own_draw_count: 5,
        opponent_draw_count: 2,
        requires_own_pokemon_knocked_out_during_opponents_last_turn?: true
      }
    )
  end
end
