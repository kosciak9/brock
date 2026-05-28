defmodule Brock.Tcg.Sim.StateMachines.TurnLifecycle do
  @moduledoc """
  Lifecycle for a single player's turn.
  """

  alias Brock.Tcg.Sim.StateMachine

  @transitions %{
    not_in_turn: %{start_turn: :start_turn},
    start_turn: %{draw_for_turn: :draw_for_turn, skip_draw_for_turn: :action_window},
    draw_for_turn: %{open_action_window: :action_window},
    action_window: %{declare_attack: :attack_declared, end_turn: :end_turn},
    attack_declared: %{resolve_attack: :attack_resolving},
    attack_resolving: %{finish_attack: :end_turn},
    end_turn: %{between_turns: :not_in_turn}
  }

  @spec transition(atom(), atom()) ::
          {:ok, atom()} | {:error, Brock.Tcg.Sim.IllegalTransition.t()}
  def transition(state, event),
    do: StateMachine.transition(__MODULE__, @transitions, state, event)

  def transitions, do: @transitions
end
