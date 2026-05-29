defmodule Brock.Tcg.Cards.Behaviors.SSP do
  @moduledoc false

  use Brock.Tcg.Cards.DSL

  card "SSP-170" do
    card_effect(effect: %{type: :search_pokemon_ex_to_hand, max_targets: 3})
  end
end
