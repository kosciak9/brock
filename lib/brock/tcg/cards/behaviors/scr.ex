defmodule Brock.Tcg.Cards.Behaviors.SCR do
  @moduledoc false

  use Brock.Tcg.Cards.DSL

  card "SCR-012" do
    attack(:spray_fluid, effect: nil)
  end
end
