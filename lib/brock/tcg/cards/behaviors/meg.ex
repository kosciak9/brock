defmodule Brock.Tcg.Cards.Behaviors.MEG do
  @moduledoc false

  use Brock.Tcg.Cards.DSL

  card "MEG-117" do
    card_effect(
      effect: %{
        type: :same_turn_grass_evolution_exception,
        except_first_turn?: true
      }
    )
  end
end
