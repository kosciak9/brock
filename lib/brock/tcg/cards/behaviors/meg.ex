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

  card "MEG-115" do
    card_effect(effect: %{type: :move_basic_energy_between_own_pokemon})
  end
end
