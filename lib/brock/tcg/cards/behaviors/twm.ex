defmodule Brock.Tcg.Cards.Behaviors.TWM do
  @moduledoc false

  use Brock.Tcg.Cards.DSL

  card "TWM-130" do
    attack(:phantom_dive,
      effect: %{type: :opponent_bench_damage_counters, total_counters: 6}
    )
  end
end
