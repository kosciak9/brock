defmodule Brock.Tcg.Sim.Invariants do
  @moduledoc """
  State invariant checks for the simulator.

  These checks are intentionally strict because the simulator must be exact
  within supported scope and undo/redo must not duplicate or lose cards.
  """

  alias Brock.Tcg.Sim.GameState

  @spec validate_card_accounting(GameState.t()) :: :ok | {:error, term()}
  def validate_card_accounting(%GameState{} = state) do
    state.players
    |> Enum.reduce_while(:ok, fn {player_id, player}, :ok ->
      cards = cards_for_player(player) ++ stadium_for_player(state, player_id)
      ids = Enum.map(cards, & &1.instance_id)

      cond do
        player.expected_card_count && length(cards) != player.expected_card_count ->
          {:halt,
           {:error, {:wrong_card_count, player_id, length(cards), player.expected_card_count}}}

        length(ids) != length(Enum.uniq(ids)) ->
          {:halt, {:error, {:duplicate_card_instance, player_id}}}

        true ->
          {:cont, :ok}
      end
    end)
  end

  def cards_for_player(player) do
    [player.active]
    |> Enum.reject(&is_nil/1)
    |> Enum.flat_map(&card_tree/1)
    |> Kernel.++(Enum.flat_map(player.bench, &card_tree/1))
    |> Kernel.++(Enum.flat_map(player.deck, &card_tree/1))
    |> Kernel.++(Enum.flat_map(player.hand, &card_tree/1))
    |> Kernel.++(Enum.flat_map(player.prizes, &card_tree/1))
    |> Kernel.++(Enum.flat_map(player.discard, &card_tree/1))
    |> Kernel.++(Enum.flat_map(player.lost_zone, &card_tree/1))
  end

  defp stadium_for_player(%{stadium: %{owner: player_id} = stadium}, player_id), do: [stadium]
  defp stadium_for_player(_state, _player_id), do: []

  defp card_tree(nil), do: []

  defp card_tree(card) do
    [card]
    |> Kernel.++(Enum.flat_map(card.attachments, &card_tree/1))
    |> Kernel.++(card_tree(card.tool))
    |> Kernel.++(Enum.flat_map(card.evolved_from, &card_tree/1))
  end
end
