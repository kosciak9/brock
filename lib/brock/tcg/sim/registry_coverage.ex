defmodule Brock.Tcg.Sim.RegistryCoverage do
  @moduledoc """
  Coverage report for the current metadata-backed simulator registry facade.

  This is the Phase 2 bridge report while executable card behavior remains in
  local overlays and static metadata comes from the committed TCGdex cache.
  """

  alias Brock.Tcg.Sim.CardRegistry
  alias Brock.Tcg.Sim.Decks.Alakazam27147
  alias Brock.Tcg.Sim.Decks.Dragapult27431

  @decks [
    %{id: "27431", name: "Dragapult", module: Dragapult27431},
    %{id: "27147", name: "Alakazam/Dudunsparce", module: Alakazam27147}
  ]

  @implemented_card_behaviors %{
    "MEG-119" => :lillies_determination,
    "SCR-133" => :crispin,
    "MEG-114" => :boss_orders,
    "POR-076" => :judge,
    "PFL-087" => :dawn,
    "POR-071" => :crushing_hammer,
    "TEF-144" => :buddy_buddy_poffin,
    "POR-081" => :poke_pad,
    "MEG-131" => :ultra_ball,
    "ASC-196" => :night_stretcher,
    "TWM-165" => :unfair_stamp,
    "MEG-127" => :risky_ruins,
    "DRI-180" => :team_rockets_watchtower,
    "WHT-084" => :hilda,
    "TWM-155" => :lanas_aid,
    "MEG-125" => :rare_candy,
    "TWM-148" => :enhanced_hammer,
    "DRI-168" => :sacred_ash,
    "TWM-150" => :handheld_fan,
    "ASC-181" => :air_balloon,
    "MEG-117" => :forest_of_vitality
  }

  @implemented_effect_types MapSet.new([
                              :active_damage_counters_per_hand_card,
                              :bench_basic_psychic_from_deck_when_attached_to_psychic,
                              :bonus_damage_if_defender_pokemon_ex,
                              :confuse_defender_active,
                              :damage_one_opponent_pokemon,
                              :draw_if_own_pokemon_knocked_out_last_turn,
                              :draw_then_shuffle_self_into_deck,
                              :draw_when_attached_from_hand,
                              :evolution_draw,
                              :lock_opponent_items_next_turn,
                              :move_damage_counters,
                              :opponent_bench_damage_counters,
                              :opponent_cannot_play_ace_spec_if_tool_attached,
                              :pokemon_lose_self_knock_out_abilities,
                              :prevent_attack_damage_and_effects_to_bench,
                              :recover_trainer_from_discard_to_hand,
                              :return_attacker_and_attached_to_hand,
                              :search_supporter_when_benched_from_hand,
                              :self_damage,
                              :switch_self_with_bench,
                              :top_two_choose_one_to_hand_other_to_bottom
                            ])

  def report do
    deck_index = deck_index()

    cards =
      CardRegistry.supported_card_ids()
      |> Enum.map(&card_report(&1, deck_index))

    %{
      source: :metadata_backed_registry,
      decks: deck_reports(),
      cards: cards,
      summary: summary(cards)
    }
  end

  def deck_reports do
    Enum.map(@decks, fn deck ->
      counts = deck.module.counts()
      card_ids = Enum.map(counts, &elem(&1, 0))

      %{
        id: deck.id,
        name: deck.name,
        module: deck.module,
        source_url: deck.module.source_url(),
        card_count: Enum.sum(Enum.map(counts, &elem(&1, 1))),
        unique_card_count: length(card_ids),
        unsupported_card_ids: Enum.reject(card_ids, &supported_card?/1)
      }
    end)
  end

  defp card_report(card_id, deck_index) do
    metadata = CardRegistry.fetch!(card_id)
    families = behavior_families(card_id, metadata)

    %{
      card_id: card_id,
      name: metadata.name,
      decks: Map.get(deck_index, card_id, []),
      metadata_status: :metadata_cached,
      behavior_status: aggregate_behavior_status(families),
      behavior_families: families
    }
  end

  defp behavior_families(card_id, %{supertype: :pokemon} = metadata) do
    ability_families(metadata) ++ attack_families(card_id, metadata)
  end

  defp behavior_families(card_id, %{supertype: :trainer} = metadata) do
    family = Map.fetch!(metadata, :trainer_type)

    case Map.fetch(@implemented_card_behaviors, card_id) do
      {:ok, behavior} ->
        [%{family: family, id: behavior, name: metadata.name, status: :implemented}]

      :error ->
        [%{family: family, id: nil, name: metadata.name, status: :behavior_missing}]
    end
  end

  defp behavior_families(_card_id, %{supertype: :energy} = metadata) do
    effect = Map.get(metadata, :effect)

    [
      %{
        family: :energy,
        id: Map.get(effect || %{}, :type, :energy_attachment),
        name: metadata.name,
        status: effect_status(effect)
      }
    ]
  end

  defp ability_families(metadata) do
    metadata
    |> Map.get(:abilities, %{})
    |> Enum.map(fn {ability_id, ability} ->
      %{
        family: :ability,
        id: ability_id,
        name: ability.name,
        status: effect_status(Map.get(ability, :effect))
      }
    end)
  end

  defp attack_families(card_id, metadata) do
    metadata
    |> Map.get(:attacks, %{})
    |> Enum.map(fn {attack_id, attack} ->
      %{
        family: :attack,
        id: attack_id,
        name: attack.name,
        status: attack_status(card_id, attack)
      }
    end)
  end

  defp attack_status(_card_id, %{effect: effect}), do: effect_status(effect)

  defp attack_status(_card_id, %{damage: damage}) when is_integer(damage) and damage > 0,
    do: :generic_damage_only

  defp attack_status(_card_id, _attack), do: :behavior_missing

  defp effect_status(nil), do: :implemented

  defp effect_status(%{type: effect_type}) do
    if MapSet.member?(@implemented_effect_types, effect_type) do
      :implemented
    else
      :unsupported_effect
    end
  end

  defp effect_status(_effect), do: :unsupported_effect

  defp aggregate_behavior_status([]), do: :implemented

  defp aggregate_behavior_status(families) do
    statuses = Enum.map(families, & &1.status)

    cond do
      :unsupported_effect in statuses -> :unsupported_effect
      :behavior_missing in statuses -> :behavior_missing
      Enum.all?(statuses, &(&1 == :generic_damage_only)) -> :generic_damage_only
      true -> :implemented
    end
  end

  defp summary(cards) do
    %{
      card_count: length(cards),
      deck_card_count: Enum.count(cards, &(&1.decks != [])),
      metadata_statuses: status_counts(cards, :metadata_status),
      behavior_statuses: status_counts(cards, :behavior_status),
      behavior_family_statuses: behavior_family_statuses(cards)
    }
  end

  defp status_counts(rows, key) do
    rows
    |> Enum.frequencies_by(&Map.fetch!(&1, key))
    |> Enum.sort_by(fn {status, _count} -> status end)
    |> Map.new()
  end

  defp behavior_family_statuses(cards) do
    cards
    |> Enum.flat_map(& &1.behavior_families)
    |> Enum.frequencies_by(& &1.status)
    |> Enum.sort_by(fn {status, _count} -> status end)
    |> Map.new()
  end

  defp deck_index do
    @decks
    |> Enum.flat_map(fn deck ->
      Enum.map(deck.module.counts(), fn {card_id, _count} -> {card_id, deck.id} end)
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Map.new(fn {card_id, deck_ids} -> {card_id, Enum.sort(deck_ids)} end)
  end

  defp supported_card?(card_id), do: match?({:ok, _card}, CardRegistry.fetch(card_id))
end
