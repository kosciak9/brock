defmodule Brock.Tcg.Cards.Behaviors.DRI do
  @moduledoc false

  use Brock.Tcg.Cards.DSL

  card "DRI-178" do
    card_effect(effect: %{type: :search_team_rocket_supporter_to_hand})
  end
end
