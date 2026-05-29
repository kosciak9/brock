defmodule Brock.Tcg.Cards.Behaviors.MEG do
  @moduledoc false

  use Brock.Tcg.Cards.DSL

  card "MEG-055" do
    ability(:psychic_draw, effect: %{type: :evolution_draw, count: 2})
    attack(:super_psy_bolt, effect: nil)
  end

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

  card "MEG-132" do
    card_effect(
      effect: %{type: :heal_mega_evolution_pokemon_ex_then_return_attached_energy_to_hand}
    )
  end
end
