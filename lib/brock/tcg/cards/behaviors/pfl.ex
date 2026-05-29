defmodule Brock.Tcg.Cards.Behaviors.PFL do
  @moduledoc false

  use Brock.Tcg.Cards.DSL

  card "PFL-083" do
    attack(:run_around, effect: %{type: :switch_self_with_bench})
    attack(:kick, effect: nil)
  end
end
