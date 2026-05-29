defmodule Brock.Tcg.Sim.Hooks do
  @moduledoc """
  Hook phase runner for card effects that modify or block generic engine actions.

  Hooks return `{:ok, state}` when play should continue or `{:halt, reason}`
  when a card effect prevents the action. Reducers normalize halted hooks into
  their existing `{:error, reason}` convention.
  """

  def run(state, :before_play_trainer, context) do
    with {:ok, state} <- prevent_item_if_locked(state, context),
         {:ok, state} <- prevent_ace_spec_if_nullified(state, context) do
      {:ok, state}
    end
  end

  def run(state, :before_ability, context) do
    with {:ok, state} <- prevent_colorless_ability_if_watchtower(state, context) do
      {:ok, state}
    end
  end

  def run(state, _phase, _context), do: {:ok, state}

  defp prevent_colorless_ability_if_watchtower(
         %{stadium: %{card_id: "DRI-180"}} = _state,
         %{metadata: %{supertype: :pokemon, type: :colorless, id: card_id}}
       ),
       do: {:halt, {:ability_blocked_by_stadium, "DRI-180", card_id}}

  defp prevent_colorless_ability_if_watchtower(state, _context), do: {:ok, state}

  defp prevent_item_if_locked(state, %{
         player_id: player_id,
         metadata: %{trainer_type: :item}
       }) do
    with {:ok, player} <- fetch_player(state, player_id) do
      if player.item_cards_locked?, do: {:halt, :item_cards_locked_this_turn}, else: {:ok, state}
    else
      {:error, reason} -> {:halt, reason}
    end
  end

  defp prevent_item_if_locked(state, _context), do: {:ok, state}

  defp prevent_ace_spec_if_nullified(state, %{
         player_id: player_id,
         metadata: %{ace_spec?: true}
       }) do
    with {:ok, opponent_id} <- opponent_id(state, player_id) do
      if ace_nullifier_active?(state, opponent_id),
        do: {:halt, :ace_spec_cards_blocked_by_ace_nullifier},
        else: {:ok, state}
    else
      {:error, reason} -> {:halt, reason}
    end
  end

  defp prevent_ace_spec_if_nullified(state, _context), do: {:ok, state}

  defp ace_nullifier_active?(state, player_id) do
    case fetch_player(state, player_id) do
      {:ok, player} ->
        player
        |> in_play_cards()
        |> Enum.any?(fn pokemon -> pokemon.card_id == "SFA-040" && not is_nil(pokemon.tool) end)

      {:error, _reason} ->
        false
    end
  end

  defp opponent_id(state, player_id) do
    state.players
    |> Map.keys()
    |> Enum.reject(&(&1 == player_id))
    |> case do
      [opponent_id] -> {:ok, opponent_id}
      opponents -> {:error, {:expected_one_opponent, opponents}}
    end
  end

  defp fetch_player(state, player_id) do
    case Map.fetch(state.players, player_id) do
      {:ok, player} -> {:ok, player}
      :error -> {:error, {:unknown_player, player_id}}
    end
  end

  defp in_play_cards(player), do: [player.active | player.bench] |> Enum.reject(&is_nil/1)
end
