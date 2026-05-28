defmodule Brock.Tcg.Sim.Decks.Dragapult27431 do
  @moduledoc """
  Static decklist for Limitless deck 27431.
  """

  @source_url "https://limitlesstcg.com/decks/list/27431"

  @cards [
    {"TWM-128", 4},
    {"TWM-129", 4},
    {"TWM-130", 3},
    {"TWM-095", 2},
    {"ASC-016", 2},
    {"PFL-014", 1},
    {"ASC-142", 1},
    {"POR-062", 1},
    {"MEG-119", 4},
    {"SCR-133", 3},
    {"MEG-114", 3},
    {"POR-076", 1},
    {"PFL-087", 1},
    {"POR-071", 4},
    {"TEF-144", 4},
    {"POR-081", 4},
    {"MEG-131", 4},
    {"ASC-196", 2},
    {"TWM-165", 1},
    {"MEG-127", 1},
    {"DRI-180", 1},
    {"MEE-002", 3},
    {"MEE-005", 3},
    {"MEE-007", 3}
  ]

  def source_url, do: @source_url
  def counts, do: @cards

  def card_ids do
    Enum.flat_map(@cards, fn {card_id, count} -> List.duplicate(card_id, count) end)
  end
end
