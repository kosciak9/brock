defmodule Brock.Tcg.Cards.Behaviors.ASC do
  @moduledoc false

  use Brock.Tcg.Cards.DSL

  card "ASC-181" do
    card_effect(
      effect: %{
        type: :retreat_cost_reduction,
        energy_type: :colorless,
        amount: 2
      }
    )
  end
end
