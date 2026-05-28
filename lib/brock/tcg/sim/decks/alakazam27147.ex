defmodule Brock.Tcg.Sim.Decks.Alakazam27147 do
  @moduledoc """
  Static decklist for Limitless deck 27147.
  """

  @source_url "https://limitlesstcg.com/decks/list/27147"

  @cards [
    {"MEG-054", 4},
    {"MEG-055", 4},
    {"MEG-056", 3},
    {"JTG-120", 3},
    {"TEF-129", 3},
    {"TEF-023", 1},
    {"TEF-024", 1},
    {"SFA-040", 1},
    {"ASC-039", 1},
    {"ASC-142", 1},
    {"SSP-087", 1},
    {"PFL-087", 4},
    {"WHT-084", 3},
    {"MEG-114", 2},
    {"TWM-155", 1},
    {"TEF-144", 4},
    {"POR-081", 4},
    {"MEG-125", 3},
    {"TWM-148", 2},
    {"DRI-168", 1},
    {"ASC-196", 1},
    {"TWM-150", 2},
    {"ASC-181", 1},
    {"MEG-117", 3},
    {"POR-088", 4},
    {"MEE-005", 1},
    {"SSP-191", 1}
  ]

  def source_url, do: @source_url
  def counts, do: @cards

  def card_ids do
    Enum.flat_map(@cards, fn {card_id, count} -> List.duplicate(card_id, count) end)
  end
end
