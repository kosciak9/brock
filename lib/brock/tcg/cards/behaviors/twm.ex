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
end
