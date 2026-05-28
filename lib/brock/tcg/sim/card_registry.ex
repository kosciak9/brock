defmodule Brock.Tcg.Sim.CardRegistry do
  @moduledoc """
  Static registry for the first simulator slice.

  The registry is intentionally explicit. Unsupported cards fail loudly instead
  of being approximated.
  """

  @cards %{
    "TWM-128" => %{
      name: "Dreepy",
      supertype: :pokemon,
      stage: :basic,
      hp: 70,
      prize_count: 1,
      retreat_cost: [:colorless],
      attacks: %{
        petty_grudge: %{name: "Petty Grudge", cost: [:psychic], damage: 10},
        bite: %{name: "Bite", cost: [:fire, :psychic], damage: 40}
      }
    },
    "TWM-129" => %{
      name: "Drakloak",
      supertype: :pokemon,
      stage: :stage_1,
      evolves_from: "TWM-128",
      hp: 90,
      prize_count: 1,
      retreat_cost: [:colorless],
      abilities: %{
        recon_directive: %{
          name: "Recon Directive",
          effect: %{type: :top_two_choose_one_to_hand_other_to_bottom}
        }
      },
      attacks: %{
        dragon_headbutt: %{name: "Dragon Headbutt", cost: [:fire, :psychic], damage: 70}
      }
    },
    "TWM-130" => %{
      name: "Dragapult ex",
      supertype: :pokemon,
      stage: :stage_2,
      evolves_from: "TWM-129",
      rule_box?: true,
      hp: 320,
      prize_count: 2,
      retreat_cost: [:colorless],
      attacks: %{
        jet_headbutt: %{name: "Jet Headbutt", cost: [:colorless], damage: 70},
        phantom_dive: %{
          name: "Phantom Dive",
          cost: [:fire, :psychic],
          damage: 200,
          effect: %{type: :opponent_bench_damage_counters, total_counters: 6}
        }
      }
    },
    "TWM-095" => %{name: "Munkidori", supertype: :pokemon, stage: :basic, hp: 110, prize_count: 1},
    "ASC-016" => %{
      name: "Budew",
      supertype: :pokemon,
      stage: :basic,
      hp: 30,
      prize_count: 1,
      attacks: %{
        itchy_pollen: %{
          name: "Itchy Pollen",
          cost: [],
          damage: 10,
          effect: %{type: :lock_opponent_items_next_turn}
        }
      }
    },
    "PFL-014" => %{
      name: "Moltres",
      supertype: :pokemon,
      stage: :basic,
      hp: 120,
      prize_count: 1,
      retreat_cost: [:colorless],
      attacks: %{
        fighting_wings: %{
          name: "Fighting Wings",
          cost: [:fire],
          damage: 20,
          effect: %{type: :bonus_damage_if_defender_pokemon_ex, bonus_damage: 90}
        }
      }
    },
    "ASC-142" => %{
      name: "Fezandipiti ex",
      supertype: :pokemon,
      stage: :basic,
      rule_box?: true,
      hp: 210,
      prize_count: 2
    },
    "POR-062" => %{
      name: "Meowth ex",
      supertype: :pokemon,
      stage: :basic,
      rule_box?: true,
      hp: 170,
      prize_count: 2
    },
    "MEG-119" => %{name: "Lillie's Determination", supertype: :trainer, trainer_type: :supporter},
    "SCR-133" => %{name: "Crispin", supertype: :trainer, trainer_type: :supporter},
    "MEG-114" => %{name: "Boss's Orders", supertype: :trainer, trainer_type: :supporter},
    "POR-076" => %{name: "Judge", supertype: :trainer, trainer_type: :supporter},
    "PFL-087" => %{name: "Dawn", supertype: :trainer, trainer_type: :supporter},
    "POR-071" => %{name: "Crushing Hammer", supertype: :trainer, trainer_type: :item},
    "TEF-144" => %{name: "Buddy-Buddy Poffin", supertype: :trainer, trainer_type: :item},
    "POR-081" => %{name: "Poké Pad", supertype: :trainer, trainer_type: :item},
    "MEG-131" => %{name: "Ultra Ball", supertype: :trainer, trainer_type: :item},
    "ASC-196" => %{name: "Night Stretcher", supertype: :trainer, trainer_type: :item},
    "TWM-165" => %{name: "Unfair Stamp", supertype: :trainer, trainer_type: :item},
    "MEG-127" => %{name: "Risky Ruins", supertype: :trainer, trainer_type: :stadium},
    "DRI-180" => %{name: "Team Rocket's Watchtower", supertype: :trainer, trainer_type: :stadium},
    "MEE-002" => %{
      name: "Fire Energy",
      supertype: :energy,
      energy_type: :basic,
      provides: [:fire]
    },
    "MEE-005" => %{
      name: "Psychic Energy",
      supertype: :energy,
      energy_type: :basic,
      provides: [:psychic]
    },
    "MEE-007" => %{
      name: "Darkness Energy",
      supertype: :energy,
      energy_type: :basic,
      provides: [:darkness]
    },
    "MEG-054" => %{
      name: "Abra",
      supertype: :pokemon,
      type: :psychic,
      stage: :basic,
      hp: 50,
      prize_count: 1,
      retreat_cost: [:colorless],
      attacks: %{
        teleportation_attack: %{
          name: "Teleportation Attack",
          cost: [:psychic],
          damage: 10,
          effect: %{type: :switch_self_with_bench}
        }
      }
    },
    "MEG-055" => %{
      name: "Kadabra",
      supertype: :pokemon,
      stage: :stage_1,
      evolves_from: "MEG-054",
      hp: 80,
      prize_count: 1,
      retreat_cost: [:colorless],
      abilities: %{
        psychic_draw: %{name: "Psychic Draw", effect: %{type: :evolution_draw, count: 2}}
      },
      attacks: %{
        super_psy_bolt: %{name: "Super Psy Bolt", cost: [:psychic], damage: 30}
      }
    },
    "MEG-056" => %{
      name: "Alakazam",
      supertype: :pokemon,
      stage: :stage_2,
      evolves_from: "MEG-055",
      hp: 140,
      prize_count: 1,
      retreat_cost: [:colorless],
      abilities: %{
        psychic_draw: %{name: "Psychic Draw", effect: %{type: :evolution_draw, count: 3}}
      },
      attacks: %{
        powerful_hand: %{
          name: "Powerful Hand",
          cost: [:psychic],
          damage: 0,
          effect: %{type: :active_damage_counters_per_hand_card, counters_per_card: 2}
        }
      }
    },
    "JTG-120" => %{
      name: "Dunsparce",
      supertype: :pokemon,
      type: :colorless,
      stage: :basic,
      hp: 70,
      prize_count: 1,
      retreat_cost: [:colorless],
      attacks: %{
        trading_places: %{
          name: "Trading Places",
          cost: [:colorless],
          damage: 0,
          effect: %{type: :switch_self_with_bench}
        },
        ram: %{name: "Ram", cost: [:colorless, :colorless], damage: 20}
      }
    },
    "TEF-129" => %{
      name: "Dudunsparce",
      supertype: :pokemon,
      type: :colorless,
      stage: :stage_1,
      evolves_from: "JTG-120",
      hp: 140,
      prize_count: 1,
      retreat_cost: [:colorless, :colorless, :colorless],
      abilities: %{
        run_away_draw: %{
          name: "Run Away Draw",
          effect: %{type: :draw_then_shuffle_self_into_deck, count: 3}
        }
      },
      attacks: %{
        land_crush: %{name: "Land Crush", cost: [:colorless, :colorless, :colorless], damage: 90}
      }
    },
    "TEF-023" => %{
      name: "Rellor",
      supertype: :pokemon,
      type: :grass,
      stage: :basic,
      hp: 50,
      prize_count: 1,
      attacks: %{
        slight_intrusion: %{
          name: "Slight Intrusion",
          cost: [:colorless],
          damage: 30,
          effect: %{type: :self_damage, damage: 10}
        }
      }
    },
    "TEF-024" => %{
      name: "Rabsca",
      supertype: :pokemon,
      type: :grass,
      stage: :stage_1,
      evolves_from: "TEF-023",
      hp: 70,
      prize_count: 1,
      abilities: %{
        spherical_shield: %{
          name: "Spherical Shield",
          effect: %{type: :prevent_attack_damage_and_effects_to_bench}
        }
      }
    },
    "SFA-040" => %{name: "Genesect", supertype: :pokemon, stage: :basic, hp: 110, prize_count: 1},
    "ASC-039" => %{name: "Psyduck", supertype: :pokemon, stage: :basic, hp: 70, prize_count: 1},
    "SSP-087" => %{name: "Dedenne", supertype: :pokemon, stage: :basic, hp: 70, prize_count: 1},
    "WHT-084" => %{name: "Hilda", supertype: :trainer, trainer_type: :supporter},
    "TWM-155" => %{name: "Lana's Aid", supertype: :trainer, trainer_type: :supporter},
    "MEG-125" => %{name: "Rare Candy", supertype: :trainer, trainer_type: :item},
    "TWM-148" => %{name: "Enhanced Hammer", supertype: :trainer, trainer_type: :item},
    "DRI-168" => %{name: "Sacred Ash", supertype: :trainer, trainer_type: :item},
    "TWM-150" => %{name: "Handheld Fan", supertype: :trainer, trainer_type: :tool},
    "ASC-181" => %{name: "Air Balloon", supertype: :trainer, trainer_type: :tool},
    "MEG-117" => %{name: "Forest of Vitality", supertype: :trainer, trainer_type: :stadium},
    "POR-088" => %{
      name: "Telepathic Psychic Energy",
      supertype: :energy,
      energy_type: :special,
      provides: [:psychic]
    },
    "SSP-191" => %{
      name: "Enriching Energy",
      supertype: :energy,
      energy_type: :special,
      provides: [:colorless]
    }
  }

  def fetch(card_id) do
    case Map.fetch(@cards, card_id) do
      {:ok, card} -> {:ok, Map.put(card, :id, card_id)}
      :error -> {:error, {:unsupported_card, card_id}}
    end
  end

  def fetch!(card_id) do
    case fetch(card_id) do
      {:ok, card} -> card
      {:error, reason} -> raise ArgumentError, inspect(reason)
    end
  end

  def basic_pokemon?(card_id) do
    match?({:ok, %{supertype: :pokemon, stage: :basic}}, fetch(card_id))
  end

  def fetch_attack(card_id, attack_id) do
    with {:ok, %{attacks: attacks}} <- fetch(card_id),
         {:ok, attack} <- Map.fetch(attacks, attack_id) do
      {:ok, Map.put(attack, :id, attack_id)}
    else
      {:ok, _card_without_attacks} -> {:error, {:unsupported_attack, card_id, attack_id}}
      :error -> {:error, {:unsupported_attack, card_id, attack_id}}
      {:error, reason} -> {:error, reason}
    end
  end

  def supported_card_ids, do: Map.keys(@cards) |> Enum.sort()
end
