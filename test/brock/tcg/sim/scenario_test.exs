defmodule Brock.Tcg.Sim.ScenarioTest do
  use ExUnit.Case, async: true

  alias Brock.Tcg.Sim.Action
  alias Brock.Tcg.Sim.CardRegistry
  alias Brock.Tcg.Sim.Decks.Alakazam27147
  alias Brock.Tcg.Sim.Decks.Dragapult27431
  alias Brock.Tcg.Sim.Engine
  alias Brock.Tcg.Sim.Invariants

  test "lucky quick knockout wins before the opponent can stabilize" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    target = state.players.alakazam.active

    assert {:ok, state} = scripted_attack(state, :dragapult, :alakazam, target.instance_id, 50)

    assert state.winner == :dragapult
    assert state.game_lifecycle == :finished
    assert length(state.players.dragapult.prizes) == 5
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "unlucky long game ends when Alakazam runs out of cards" do
    assert {:ok, state} = setup_game(active_player: :dragapult, alakazam_bench?: true)

    assert {:ok, state} = pass_turn(state, :dragapult)
    state = put_in(state.players.alakazam.deck, [])
    state = put_in(state.players.alakazam.expected_card_count, 13)

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :draw_for_turn, player_id: :alakazam})

    assert state.winner == :dragapult
    assert state.game_lifecycle == :finished
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "crazy combo scenario touches every card id from both fixed decklists" do
    assert {:ok, state} = setup_game(active_player: :dragapult, alakazam_bench?: true)

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :draw_for_turn, player_id: :dragapult})

    assert {:ok, state} = Engine.apply_action(state, %Action{type: :open_action_window})

    {state, dragapult_touched} =
      exercise_unique_cards(state, :dragapult, Dragapult27431.card_ids())

    assert :ok = Invariants.validate_card_accounting(state)

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :end_turn, player_id: :dragapult})

    assert {:ok, state} = Engine.apply_action(state, %Action{type: :start_next_turn})

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :draw_for_turn, player_id: :alakazam})

    assert {:ok, state} = Engine.apply_action(state, %Action{type: :open_action_window})

    {state, alakazam_touched} = exercise_unique_cards(state, :alakazam, Alakazam27147.card_ids())

    expected =
      Dragapult27431.card_ids()
      |> Kernel.++(Alakazam27147.card_ids())
      |> MapSet.new()

    assert MapSet.union(dragapult_touched, alakazam_touched) == expected
    assert state.stadium.card_id in ["MEG-127", "DRI-180", "MEG-117"]
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "marathon prize race can go through replacements before a final prize finish" do
    assert {:ok, state} = setup_game(active_player: :dragapult, alakazam_bench?: true)
    abra = state.players.alakazam.active
    [replacement | _] = state.players.alakazam.bench

    assert {:ok, state} = scripted_attack(state, :dragapult, :alakazam, abra.instance_id, 50)
    assert state.game_lifecycle == :replacing_active

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :choose_replacement_active,
               player_id: :alakazam,
               params: %{instance_id: replacement.instance_id}
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :finish_attack, player_id: :dragapult})

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :end_turn, player_id: :dragapult})

    assert {:ok, state} = Engine.apply_action(state, %Action{type: :start_next_turn})
    assert {:ok, state} = pass_turn(state, :alakazam)

    [final_prize | already_taken] = state.players.dragapult.prizes

    dragapult = %{
      state.players.dragapult
      | prizes: [final_prize],
        hand: already_taken ++ state.players.dragapult.hand
    }

    state = put_in(state.players.dragapult, dragapult)
    active = state.players.alakazam.active

    assert {:ok, state} = scripted_attack(state, :dragapult, :alakazam, active.instance_id, 200)

    assert state.winner == :dragapult
    assert state.players.dragapult.prizes == []
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Rare Candy evolves a Basic directly into a Stage 2 and discards the item" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = pass_turn(state, :dragapult)
    assert {:ok, state} = open_turn(state, :alakazam)

    assert {:ok, state, candy} = search_to_hand_by_card_id(state, :alakazam, "MEG-125")
    assert {:ok, state, alakazam} = search_to_hand_by_card_id(state, :alakazam, "MEG-056")
    abra = state.players.alakazam.active

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :rare_candy,
               player_id: :alakazam,
               params: %{
                 instance_id: candy.instance_id,
                 evolution_id: alakazam.instance_id,
                 target_id: abra.instance_id
               }
             })

    assert state.players.alakazam.active.card_id == "MEG-056"
    assert [evolved_from] = state.players.alakazam.active.evolved_from
    assert evolved_from.card_id == "MEG-054"
    assert Enum.any?(state.players.alakazam.discard, &(&1.card_id == "MEG-125"))
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Buddy-Buddy Poffin benches two low-HP Basic Pokemon from deck" do
    assert {:ok, state} = setup_game(active_player: :alakazam)
    assert {:ok, state} = open_turn(state, :alakazam)

    poffin = card_in_hand(state, :alakazam, "TEF-144")

    [basic_1, basic_2 | _] =
      Enum.filter(state.players.alakazam.deck, fn card ->
        metadata = CardRegistry.fetch!(card.card_id)
        metadata[:supertype] == :pokemon && metadata[:stage] == :basic && metadata[:hp] <= 70
      end)

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :buddy_buddy_poffin,
               player_id: :alakazam,
               params: %{
                 instance_id: poffin.instance_id,
                 target_ids: [basic_1.instance_id, basic_2.instance_id]
               }
             })

    assert Enum.any?(state.players.alakazam.bench, &(&1.instance_id == basic_1.instance_id))
    assert Enum.any?(state.players.alakazam.bench, &(&1.instance_id == basic_2.instance_id))
    assert Enum.any?(state.players.alakazam.discard, &(&1.instance_id == poffin.instance_id))
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Ultra Ball discards two cards and searches any Pokemon" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = open_turn(state, :dragapult)

    assert {:ok, state, ultra_ball} = search_to_hand_by_card_id(state, :dragapult, "MEG-131")

    [discard_1, discard_2 | _] =
      Enum.reject(state.players.dragapult.hand, &(&1.instance_id == ultra_ball.instance_id))

    dragapult_ex = card_in_deck(state, :dragapult, "TWM-130")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :ultra_ball,
               player_id: :dragapult,
               params: %{
                 instance_id: ultra_ball.instance_id,
                 discard_ids: [discard_1.instance_id, discard_2.instance_id],
                 target_id: dragapult_ex.instance_id
               }
             })

    assert Enum.any?(state.players.dragapult.hand, &(&1.instance_id == dragapult_ex.instance_id))
    assert Enum.any?(state.players.dragapult.discard, &(&1.instance_id == ultra_ball.instance_id))
    assert Enum.any?(state.players.dragapult.discard, &(&1.instance_id == discard_1.instance_id))
    assert Enum.any?(state.players.dragapult.discard, &(&1.instance_id == discard_2.instance_id))
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Boss's Orders switches an opponent Benched Pokemon into the Active spot" do
    assert {:ok, state} = setup_game(active_player: :dragapult, alakazam_bench?: true)
    assert {:ok, state} = open_turn(state, :dragapult)
    assert {:ok, state, boss} = search_to_hand_by_card_id(state, :dragapult, "MEG-114")

    old_active = state.players.alakazam.active
    [target] = state.players.alakazam.bench

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :boss_orders,
               player_id: :dragapult,
               params: %{instance_id: boss.instance_id, target_id: target.instance_id}
             })

    assert state.players.alakazam.active.instance_id == target.instance_id
    assert Enum.any?(state.players.alakazam.bench, &(&1.instance_id == old_active.instance_id))
    assert state.players.dragapult.supporter_played?
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Hammer items discard attached Energy with explicit supported scope" do
    assert {:ok, state} = setup_game(active_player: :alakazam)
    assert {:ok, state} = open_turn(state, :alakazam)

    energy = card_in_hand(state, :alakazam, "POR-088")
    abra = state.players.alakazam.active

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :attach_energy,
               player_id: :alakazam,
               params: %{instance_id: energy.instance_id, target_id: abra.instance_id}
             })

    attached = hd(state.players.alakazam.active.attachments)

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :end_turn, player_id: :alakazam})

    assert {:ok, state} = Engine.apply_action(state, %Action{type: :start_next_turn})
    assert {:ok, state} = open_turn(state, :dragapult)
    assert {:ok, state, hammer} = search_to_hand_by_card_id(state, :dragapult, "POR-071")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :discard_attached_energy_with_item,
               player_id: :dragapult,
               params: %{
                 instance_id: hammer.instance_id,
                 target_player_id: :alakazam,
                 target_id: state.players.alakazam.active.instance_id,
                 attachment_id: attached.instance_id
               }
             })

    assert state.players.alakazam.active.attachments == []
    assert Enum.any?(state.players.alakazam.discard, &(&1.instance_id == attached.instance_id))
    assert Enum.any?(state.players.dragapult.discard, &(&1.instance_id == hammer.instance_id))
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Enhanced Hammer rejects Basic Energy in its supported scope" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = open_turn(state, :dragapult)

    energy = card_in_hand(state, :dragapult, "MEE-005")
    dreepy = state.players.dragapult.active

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :attach_energy,
               player_id: :dragapult,
               params: %{instance_id: energy.instance_id, target_id: dreepy.instance_id}
             })

    attached = hd(state.players.dragapult.active.attachments)

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :end_turn, player_id: :dragapult})

    assert {:ok, state} = Engine.apply_action(state, %Action{type: :start_next_turn})
    assert {:ok, state} = open_turn(state, :alakazam)
    assert {:ok, state, enhanced_hammer} = search_to_hand_by_card_id(state, :alakazam, "TWM-148")

    assert {:error, {:enhanced_hammer_requires_special_energy, "MEE-005"}} =
             Engine.apply_action(state, %Action{
               type: :discard_attached_energy_with_item,
               player_id: :alakazam,
               params: %{
                 instance_id: enhanced_hammer.instance_id,
                 target_player_id: :dragapult,
                 target_id: state.players.dragapult.active.instance_id,
                 attachment_id: attached.instance_id
               }
             })
  end

  test "Night Stretcher recovers a Pokemon or Basic Energy from discard" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = open_turn(state, :dragapult)

    assert {:ok, state, stretcher} = search_to_hand_by_card_id(state, :dragapult, "ASC-196")
    energy = card_in_hand(state, :dragapult, "MEE-002")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :discard_from_hand,
               player_id: :dragapult,
               params: %{instance_id: energy.instance_id}
             })

    discarded_energy =
      Enum.find(state.players.dragapult.discard, &(&1.instance_id == energy.instance_id))

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :night_stretcher,
               player_id: :dragapult,
               params: %{
                 instance_id: stretcher.instance_id,
                 target_id: discarded_energy.instance_id
               }
             })

    assert Enum.any?(state.players.dragapult.hand, &(&1.instance_id == energy.instance_id))
    assert Enum.any?(state.players.dragapult.discard, &(&1.instance_id == stretcher.instance_id))
    refute Enum.any?(state.players.dragapult.discard, &(&1.instance_id == energy.instance_id))
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Crispin searches different Basic Energy types and attaches one" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = open_turn(state, :dragapult)

    assert {:ok, state, crispin} = search_to_hand_by_card_id(state, :dragapult, "SCR-133")
    fire = card_in_deck(state, :dragapult, "MEE-002")
    psychic = card_in_deck(state, :dragapult, "MEE-005")
    target = state.players.dragapult.active

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :crispin,
               player_id: :dragapult,
               params: %{
                 instance_id: crispin.instance_id,
                 hand_energy_id: fire.instance_id,
                 attach_energy_id: psychic.instance_id,
                 target_id: target.instance_id
               }
             })

    assert Enum.any?(state.players.dragapult.hand, &(&1.instance_id == fire.instance_id))

    assert Enum.any?(
             state.players.dragapult.active.attachments,
             &(&1.instance_id == psychic.instance_id)
           )

    assert Enum.any?(state.players.dragapult.discard, &(&1.instance_id == crispin.instance_id))
    assert state.players.dragapult.supporter_played?
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Lillie's Determination shuffles hand then draws 8 with six Prizes remaining" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = open_turn(state, :dragapult)

    lillie = card_in_hand(state, :dragapult, "MEG-119")

    hand_without_lillie =
      Enum.reject(state.players.dragapult.hand, &(&1.instance_id == lillie.instance_id))

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :lillies_determination,
               player_id: :dragapult,
               params: %{instance_id: lillie.instance_id}
             })

    assert length(state.players.dragapult.hand) == 8
    assert Enum.any?(state.players.dragapult.discard, &(&1.instance_id == lillie.instance_id))
    assert state.players.dragapult.supporter_played?

    for shuffled_card <- hand_without_lillie do
      refute Enum.any?(
               state.players.dragapult.hand,
               &(&1.instance_id == shuffled_card.instance_id)
             )
    end

    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Unfair Stamp requires a KO during the opponent's last turn" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = open_turn(state, :dragapult)
    assert {:ok, state, stamp} = search_to_hand_by_card_id(state, :dragapult, "TWM-165")

    assert {:error, :unfair_stamp_requires_ko_during_opponents_last_turn} =
             Engine.apply_action(state, %Action{
               type: :unfair_stamp,
               player_id: :dragapult,
               params: %{instance_id: stamp.instance_id}
             })
  end

  test "Unfair Stamp shuffles both hands after a KO during opponent's last turn" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = open_turn(state, :dragapult)

    budew = card_in_hand(state, :dragapult, "ASC-016")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :play_basic_to_bench,
               player_id: :dragapult,
               params: %{instance_id: budew.instance_id}
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :end_turn, player_id: :dragapult})

    assert {:ok, state} = Engine.apply_action(state, %Action{type: :start_next_turn})
    assert {:ok, state} = open_turn(state, :alakazam)

    dreepy = state.players.dragapult.active

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :declare_attack, player_id: :alakazam})

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :resolve_attack_damage,
               player_id: :alakazam,
               params: %{target_player_id: :dragapult, target_id: dreepy.instance_id, damage: 70}
             })

    assert state.players.dragapult.pokemon_knocked_out_during_opponents_last_turn?
    assert state.game_lifecycle == :replacing_active

    [replacement] = state.players.dragapult.bench

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :choose_replacement_active,
               player_id: :dragapult,
               params: %{instance_id: replacement.instance_id}
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :finish_attack, player_id: :alakazam})

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :end_turn, player_id: :alakazam})

    assert {:ok, state} = Engine.apply_action(state, %Action{type: :start_next_turn})
    assert {:ok, state} = open_turn(state, :dragapult)
    assert {:ok, state, stamp} = search_to_hand_by_card_id(state, :dragapult, "TWM-165")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :unfair_stamp,
               player_id: :dragapult,
               params: %{instance_id: stamp.instance_id}
             })

    assert length(state.players.dragapult.hand) == 5
    assert length(state.players.alakazam.hand) == 2
    assert Enum.any?(state.players.dragapult.discard, &(&1.instance_id == stamp.instance_id))
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Poké Pad searches a non-Rule Box Pokemon from deck" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = open_turn(state, :dragapult)

    assert {:ok, state, poke_pad} = search_to_hand_by_card_id(state, :dragapult, "POR-081")
    drakloak = card_in_deck(state, :dragapult, "TWM-129")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :poke_pad,
               player_id: :dragapult,
               params: %{instance_id: poke_pad.instance_id, target_id: drakloak.instance_id}
             })

    assert Enum.any?(state.players.dragapult.hand, &(&1.instance_id == drakloak.instance_id))
    assert Enum.any?(state.players.dragapult.discard, &(&1.instance_id == poke_pad.instance_id))
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Dawn searches one Basic, Stage 1, and Stage 2 Pokemon" do
    assert {:ok, state} = setup_game(active_player: :alakazam)
    assert {:ok, state} = open_turn(state, :alakazam)

    dawn = card_in_hand(state, :alakazam, "PFL-087")
    basic = pokemon_in_deck_by_stage(state, :alakazam, :basic)
    stage_1 = pokemon_in_deck_by_stage(state, :alakazam, :stage_1)
    stage_2 = pokemon_in_deck_by_stage(state, :alakazam, :stage_2)

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :dawn,
               player_id: :alakazam,
               params: %{
                 instance_id: dawn.instance_id,
                 basic_id: basic.instance_id,
                 stage_1_id: stage_1.instance_id,
                 stage_2_id: stage_2.instance_id
               }
             })

    assert Enum.any?(state.players.alakazam.hand, &(&1.instance_id == basic.instance_id))
    assert Enum.any?(state.players.alakazam.hand, &(&1.instance_id == stage_1.instance_id))
    assert Enum.any?(state.players.alakazam.hand, &(&1.instance_id == stage_2.instance_id))
    assert Enum.any?(state.players.alakazam.discard, &(&1.instance_id == dawn.instance_id))
    assert state.players.alakazam.supporter_played?
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Sacred Ash shuffles five Pokemon from discard into deck" do
    assert {:ok, state} = setup_game(active_player: :alakazam)
    assert {:ok, state} = open_turn(state, :alakazam)
    assert {:ok, state, sacred_ash} = search_to_hand_by_card_id(state, :alakazam, "DRI-168")

    {state, discarded_pokemon} =
      Enum.reduce(
        ["MEG-055", "MEG-056", "TEF-129", "TEF-023", "TEF-024"],
        {state, []},
        fn card_id, {state, discarded} ->
          assert {:ok, state, card} = search_to_hand_by_card_id(state, :alakazam, card_id)

          assert {:ok, state} =
                   Engine.apply_action(state, %Action{
                     type: :discard_from_hand,
                     player_id: :alakazam,
                     params: %{instance_id: card.instance_id}
                   })

          {state, [card | discarded]}
        end
      )

    target_ids = Enum.map(discarded_pokemon, & &1.instance_id)

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :sacred_ash,
               player_id: :alakazam,
               params: %{instance_id: sacred_ash.instance_id, target_ids: target_ids}
             })

    for card <- discarded_pokemon do
      assert Enum.any?(state.players.alakazam.deck, &(&1.instance_id == card.instance_id))
      refute Enum.any?(state.players.alakazam.discard, &(&1.instance_id == card.instance_id))
    end

    assert Enum.any?(state.players.alakazam.discard, &(&1.instance_id == sacred_ash.instance_id))
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Judge shuffles both players' hands and each draws four" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = open_turn(state, :dragapult)
    assert {:ok, state, judge} = search_to_hand_by_card_id(state, :dragapult, "POR-076")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :judge,
               player_id: :dragapult,
               params: %{instance_id: judge.instance_id}
             })

    assert length(state.players.dragapult.hand) == 4
    assert length(state.players.alakazam.hand) == 4
    assert Enum.any?(state.players.dragapult.discard, &(&1.instance_id == judge.instance_id))
    assert state.players.dragapult.supporter_played?
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Hilda searches an Evolution Pokemon and an Energy card" do
    assert {:ok, state} = setup_game(active_player: :alakazam)
    assert {:ok, state} = open_turn(state, :alakazam)
    assert {:ok, state, hilda} = search_to_hand_by_card_id(state, :alakazam, "WHT-084")

    evolution = pokemon_in_deck_by_stage(state, :alakazam, :stage_2)

    energy =
      card_in_deck(state, :alakazam, "POR-088") || card_in_deck(state, :alakazam, "MEE-005")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :hilda,
               player_id: :alakazam,
               params: %{
                 instance_id: hilda.instance_id,
                 evolution_id: evolution.instance_id,
                 energy_id: energy.instance_id
               }
             })

    assert Enum.any?(state.players.alakazam.hand, &(&1.instance_id == evolution.instance_id))
    assert Enum.any?(state.players.alakazam.hand, &(&1.instance_id == energy.instance_id))
    assert Enum.any?(state.players.alakazam.discard, &(&1.instance_id == hilda.instance_id))
    assert state.players.alakazam.supporter_played?
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Lana's Aid recovers up to three non-Rule Box Pokemon and Basic Energy" do
    assert {:ok, state} = setup_game(active_player: :alakazam)
    assert {:ok, state} = open_turn(state, :alakazam)
    assert {:ok, state, lana} = search_to_hand_by_card_id(state, :alakazam, "TWM-155")

    {state, targets} =
      Enum.reduce(["MEG-055", "TEF-129", "MEE-005"], {state, []}, fn card_id, {state, targets} ->
        {:ok, state, card} = ensure_card_in_hand(state, :alakazam, card_id)

        assert {:ok, state} =
                 Engine.apply_action(state, %Action{
                   type: :discard_from_hand,
                   player_id: :alakazam,
                   params: %{instance_id: card.instance_id}
                 })

        {state, [card | targets]}
      end)

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :lanas_aid,
               player_id: :alakazam,
               params: %{
                 instance_id: lana.instance_id,
                 target_ids: Enum.map(targets, & &1.instance_id)
               }
             })

    for target <- targets do
      assert Enum.any?(state.players.alakazam.hand, &(&1.instance_id == target.instance_id))
      refute Enum.any?(state.players.alakazam.discard, &(&1.instance_id == target.instance_id))
    end

    assert Enum.any?(state.players.alakazam.discard, &(&1.instance_id == lana.instance_id))
    assert state.players.alakazam.supporter_played?
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Air Balloon reduces retreat cost by two Colorless Energy" do
    assert {:ok, state} = setup_game(active_player: :alakazam, alakazam_bench?: true)
    assert {:ok, state} = open_turn(state, :alakazam)
    assert {:ok, state, air_balloon} = search_to_hand_by_card_id(state, :alakazam, "ASC-181")

    active = state.players.alakazam.active
    [bench_target] = state.players.alakazam.bench

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :attach_tool,
               player_id: :alakazam,
               params: %{instance_id: air_balloon.instance_id, target_id: active.instance_id}
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :retreat,
               player_id: :alakazam,
               params: %{bench_id: bench_target.instance_id, attachment_ids: []}
             })

    assert state.players.alakazam.active.instance_id == bench_target.instance_id

    benched_old_active =
      Enum.find(state.players.alakazam.bench, &(&1.instance_id == active.instance_id))

    assert benched_old_active.tool.instance_id == air_balloon.instance_id
    assert state.players.alakazam.retreated?
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "retreat pays Energy, switches with Bench, and is once per turn" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = open_turn(state, :dragapult)

    budew = card_in_hand(state, :dragapult, "ASC-016")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :play_basic_to_bench,
               player_id: :dragapult,
               params: %{instance_id: budew.instance_id}
             })

    energy = card_in_hand(state, :dragapult, "MEE-005")
    dreepy = state.players.dragapult.active

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :attach_energy,
               player_id: :dragapult,
               params: %{instance_id: energy.instance_id, target_id: dreepy.instance_id}
             })

    attached = hd(state.players.dragapult.active.attachments)
    [bench_target] = state.players.dragapult.bench

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :retreat,
               player_id: :dragapult,
               params: %{
                 bench_id: bench_target.instance_id,
                 attachment_ids: [attached.instance_id]
               }
             })

    assert state.players.dragapult.active.instance_id == bench_target.instance_id
    assert state.players.dragapult.retreated?
    assert Enum.any?(state.players.dragapult.discard, &(&1.instance_id == attached.instance_id))

    old_active = Enum.find(state.players.dragapult.bench, &(&1.instance_id == dreepy.instance_id))

    assert {:error, :already_retreated_this_turn} =
             Engine.apply_action(state, %Action{
               type: :retreat,
               player_id: :dragapult,
               params: %{bench_id: old_active.instance_id, attachment_ids: []}
             })

    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "switch action changes Active without spending retreat for turn" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = open_turn(state, :dragapult)

    budew = card_in_hand(state, :dragapult, "ASC-016")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :play_basic_to_bench,
               player_id: :dragapult,
               params: %{instance_id: budew.instance_id}
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :switch_active_with_bench,
               player_id: :dragapult,
               params: %{bench_id: budew.instance_id}
             })

    assert state.players.dragapult.active.card_id == "ASC-016"
    refute state.players.dragapult.retreated?
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Drakloak Recon Directive keeps one of top two and bottoms the other" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = pass_turn(state, :dragapult)
    assert {:ok, state} = pass_turn(state, :alakazam)
    assert {:ok, state} = open_turn(state, :dragapult)

    drakloak = card_in_hand(state, :dragapult, "TWM-129")
    dreepy = state.players.dragapult.active

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :evolve_from_hand,
               player_id: :dragapult,
               params: %{instance_id: drakloak.instance_id, target_id: dreepy.instance_id}
             })

    [chosen, bottomed | _] = state.players.dragapult.deck

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :use_ability,
               player_id: :dragapult,
               params: %{
                 source_id: state.players.dragapult.active.instance_id,
                 ability_id: :recon_directive,
                 chosen_id: chosen.instance_id
               }
             })

    assert Enum.any?(state.players.dragapult.hand, &(&1.instance_id == chosen.instance_id))
    assert List.last(state.players.dragapult.deck).instance_id == bottomed.instance_id
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Alakazam line Psychic Draw and Powerful Hand use verified card text" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = pass_turn(state, :dragapult)
    assert {:ok, state} = open_turn(state, :alakazam)

    assert {:ok, state, candy} = search_to_hand_by_card_id(state, :alakazam, "MEG-125")
    alakazam = card_in_hand(state, :alakazam, "MEG-056")
    abra = state.players.alakazam.active

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :rare_candy,
               player_id: :alakazam,
               params: %{
                 instance_id: candy.instance_id,
                 evolution_id: alakazam.instance_id,
                 target_id: abra.instance_id
               }
             })

    hand_count_before_draw = length(state.players.alakazam.hand)

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :use_ability,
               player_id: :alakazam,
               params: %{
                 source_id: state.players.alakazam.active.instance_id,
                 ability_id: :psychic_draw
               }
             })

    assert length(state.players.alakazam.hand) == hand_count_before_draw + 3

    energy = card_in_hand(state, :alakazam, "POR-088")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :attach_energy,
               player_id: :alakazam,
               params: %{
                 instance_id: energy.instance_id,
                 target_id: state.players.alakazam.active.instance_id
               }
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :declare_attack,
               player_id: :alakazam,
               params: %{attack_id: :powerful_hand}
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :resolve_declared_attack,
               player_id: :alakazam
             })

    assert state.winner == :alakazam
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Dudunsparce Run Away Draw draws then shuffles itself and stack into deck" do
    assert {:ok, state} = setup_game(active_player: :dragapult, alakazam_bench?: true)
    assert {:ok, state} = pass_turn(state, :dragapult)
    assert {:ok, state} = open_turn(state, :alakazam)

    assert {:ok, state, dudunsparce} = search_to_hand_by_card_id(state, :alakazam, "TEF-129")
    dunsparce = hd(state.players.alakazam.bench)

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :evolve_from_hand,
               player_id: :alakazam,
               params: %{instance_id: dudunsparce.instance_id, target_id: dunsparce.instance_id}
             })

    evolved = hd(state.players.alakazam.bench)
    hand_count_before = length(state.players.alakazam.hand)

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :use_ability,
               player_id: :alakazam,
               params: %{source_id: evolved.instance_id, ability_id: :run_away_draw}
             })

    assert length(state.players.alakazam.hand) == hand_count_before + 3
    refute Enum.any?(state.players.alakazam.bench, &(&1.instance_id == evolved.instance_id))
    assert Enum.any?(state.players.alakazam.deck, &(&1.card_id == "TEF-129"))
    assert Enum.any?(state.players.alakazam.deck, &(&1.card_id == "JTG-120"))
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Team Rocket's Watchtower blocks Colorless Pokemon Abilities" do
    assert {:ok, state} = setup_game(active_player: :dragapult, alakazam_bench?: true)
    assert {:ok, state} = open_turn(state, :dragapult)
    assert {:ok, state, watchtower} = search_to_hand_by_card_id(state, :dragapult, "DRI-180")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :play_stadium,
               player_id: :dragapult,
               params: %{instance_id: watchtower.instance_id}
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :end_turn, player_id: :dragapult})

    assert {:ok, state} = Engine.apply_action(state, %Action{type: :start_next_turn})
    assert {:ok, state} = open_turn(state, :alakazam)
    assert {:ok, state, dudunsparce} = search_to_hand_by_card_id(state, :alakazam, "TEF-129")
    dunsparce = hd(state.players.alakazam.bench)

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :evolve_from_hand,
               player_id: :alakazam,
               params: %{instance_id: dudunsparce.instance_id, target_id: dunsparce.instance_id}
             })

    evolved = hd(state.players.alakazam.bench)

    assert {:error, {:ability_blocked_by_stadium, "DRI-180", "TEF-129"}} =
             Engine.apply_action(state, %Action{
               type: :use_ability,
               player_id: :alakazam,
               params: %{source_id: evolved.instance_id, ability_id: :run_away_draw}
             })

    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Forest of Vitality allows same-turn Grass evolution after first turn" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = pass_turn(state, :dragapult)
    assert {:ok, state} = open_turn(state, :alakazam)
    assert {:ok, state, forest} = search_to_hand_by_card_id(state, :alakazam, "MEG-117")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :play_stadium,
               player_id: :alakazam,
               params: %{instance_id: forest.instance_id}
             })

    assert {:ok, state, rellor} = search_to_hand_by_card_id(state, :alakazam, "TEF-023")
    assert {:ok, state, rabsca} = search_to_hand_by_card_id(state, :alakazam, "TEF-024")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :play_basic_to_bench,
               player_id: :alakazam,
               params: %{instance_id: rellor.instance_id}
             })

    rellor = Enum.find(state.players.alakazam.bench, &(&1.card_id == "TEF-023"))
    assert rellor.turn_entered_play == state.turn_number

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :evolve_from_hand,
               player_id: :alakazam,
               params: %{instance_id: rabsca.instance_id, target_id: rellor.instance_id}
             })

    assert Enum.any?(state.players.alakazam.bench, &(&1.card_id == "TEF-024"))
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Rellor Slight Intrusion damages the opponent and itself" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = pass_turn(state, :dragapult)
    assert {:ok, state} = open_turn(state, :alakazam)
    assert {:ok, state, rellor} = search_to_hand_by_card_id(state, :alakazam, "TEF-023")
    assert {:ok, state, energy} = search_to_hand_by_card_id(state, :alakazam, "SSP-191")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :play_basic_to_bench,
               player_id: :alakazam,
               params: %{instance_id: rellor.instance_id}
             })

    rellor = Enum.find(state.players.alakazam.bench, &(&1.card_id == "TEF-023"))

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :attach_energy,
               player_id: :alakazam,
               params: %{instance_id: energy.instance_id, target_id: rellor.instance_id}
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :switch_active_with_bench,
               player_id: :alakazam,
               params: %{bench_id: rellor.instance_id}
             })

    dreepy = state.players.dragapult.active

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :declare_attack,
               player_id: :alakazam,
               params: %{attack_id: :slight_intrusion}
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :resolve_declared_attack,
               player_id: :alakazam
             })

    assert state.players.dragapult.active.instance_id == dreepy.instance_id
    assert state.players.dragapult.active.damage == 30
    assert state.players.alakazam.active.card_id == "TEF-023"
    assert state.players.alakazam.active.damage == 10
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Risky Ruins places damage counters on Basic non-Dark Pokemon benched during turn" do
    assert {:ok, state} = setup_game(active_player: :dragapult)
    assert {:ok, state} = open_turn(state, :dragapult)
    assert {:ok, state, risky_ruins} = search_to_hand_by_card_id(state, :dragapult, "MEG-127")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :play_stadium,
               player_id: :dragapult,
               params: %{instance_id: risky_ruins.instance_id}
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :end_turn, player_id: :dragapult})

    assert {:ok, state} = Engine.apply_action(state, %Action{type: :start_next_turn})
    assert {:ok, state} = open_turn(state, :alakazam)

    abra = card_in_hand(state, :alakazam, "MEG-054")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :play_basic_to_bench,
               player_id: :alakazam,
               params: %{instance_id: abra.instance_id}
             })

    damaged_abra = Enum.find(state.players.alakazam.bench, &(&1.instance_id == abra.instance_id))
    assert damaged_abra.damage == 20
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Handheld Fan moves Energy from attacker when attached Active is damaged" do
    assert {:ok, state} = setup_game(active_player: :dragapult, alakazam_bench?: true)
    assert {:ok, state} = pass_turn(state, :dragapult)
    assert {:ok, state} = open_turn(state, :alakazam)
    assert {:ok, state, fan} = search_to_hand_by_card_id(state, :alakazam, "TWM-150")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :attach_tool,
               player_id: :alakazam,
               params: %{
                 instance_id: fan.instance_id,
                 target_id: state.players.alakazam.active.instance_id
               }
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :end_turn, player_id: :alakazam})

    assert {:ok, state} = Engine.apply_action(state, %Action{type: :start_next_turn})
    assert {:ok, state} = open_turn(state, :dragapult)

    energy = card_in_hand(state, :dragapult, "MEE-005")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :attach_energy,
               player_id: :dragapult,
               params: %{
                 instance_id: energy.instance_id,
                 target_id: state.players.dragapult.active.instance_id
               }
             })

    attached = hd(state.players.dragapult.active.attachments)
    [fan_target] = state.players.alakazam.bench

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :declare_attack,
               player_id: :dragapult,
               params: %{
                 attack_id: :petty_grudge,
                 handheld_fan_attachment_id: attached.instance_id,
                 handheld_fan_target_id: fan_target.instance_id
               }
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :resolve_declared_attack,
               player_id: :dragapult
             })

    assert state.players.alakazam.active.damage == 10
    assert state.players.dragapult.active.attachments == []

    updated_fan_target = hd(state.players.alakazam.bench)
    assert Enum.any?(updated_fan_target.attachments, &(&1.instance_id == attached.instance_id))
    assert :ok = Invariants.validate_card_accounting(state)
  end

  test "Dragapult ex Phantom Dive damages Active and places six bench counters" do
    assert {:ok, state} = setup_game(active_player: :dragapult, alakazam_bench?: true)
    assert {:ok, state} = open_turn(state, :dragapult)

    psychic = card_in_hand(state, :dragapult, "MEE-005")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :attach_energy,
               player_id: :dragapult,
               params: %{
                 instance_id: psychic.instance_id,
                 target_id: state.players.dragapult.active.instance_id
               }
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :end_turn, player_id: :dragapult})

    assert {:ok, state} = Engine.apply_action(state, %Action{type: :start_next_turn})
    assert {:ok, state} = pass_turn(state, :alakazam)
    assert {:ok, state} = open_turn(state, :dragapult)

    fire = card_in_hand(state, :dragapult, "MEE-002")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :attach_energy,
               player_id: :dragapult,
               params: %{
                 instance_id: fire.instance_id,
                 target_id: state.players.dragapult.active.instance_id
               }
             })

    drakloak = card_in_hand(state, :dragapult, "TWM-129")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :evolve_from_hand,
               player_id: :dragapult,
               params: %{
                 instance_id: drakloak.instance_id,
                 target_id: state.players.dragapult.active.instance_id
               }
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{type: :end_turn, player_id: :dragapult})

    assert {:ok, state} = Engine.apply_action(state, %Action{type: :start_next_turn})
    assert {:ok, state} = pass_turn(state, :alakazam)
    assert {:ok, state} = open_turn(state, :dragapult)

    assert {:ok, state, dragapult_ex} = search_to_hand_by_card_id(state, :dragapult, "TWM-130")

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :evolve_from_hand,
               player_id: :dragapult,
               params: %{
                 instance_id: dragapult_ex.instance_id,
                 target_id: state.players.dragapult.active.instance_id
               }
             })

    bench_target = hd(state.players.alakazam.bench)

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :declare_attack,
               player_id: :dragapult,
               params: %{
                 attack_id: :phantom_dive,
                 bench_damage: %{bench_target.instance_id => 6}
               }
             })

    assert {:ok, state} =
             Engine.apply_action(state, %Action{
               type: :resolve_declared_attack,
               player_id: :dragapult
             })

    damaged_bench = hd(state.players.alakazam.bench)
    assert damaged_bench.damage == 60
    assert state.game_lifecycle == :replacing_active
    assert :ok = Invariants.validate_card_accounting(state)
  end

  defp exercise_unique_cards(state, player_id, card_ids) do
    card_ids
    |> MapSet.new()
    |> Enum.sort()
    |> Enum.reduce({state, MapSet.new()}, fn card_id, {state, touched} ->
      case ensure_card_in_hand(state, player_id, card_id) do
        {:ok, state, card} ->
          {:ok, state} = exercise_card_from_hand(state, player_id, card)
          {state, MapSet.put(touched, card_id)}

        {:skip, state} ->
          {state, MapSet.put(touched, card_id)}
      end
    end)
  end

  defp ensure_card_in_hand(state, player_id, card_id) do
    cond do
      card = card_in_hand(state, player_id, card_id) ->
        {:ok, state, card}

      card = card_in_deck(state, player_id, card_id) ->
        assert {:ok, state} =
                 Engine.apply_action(state, %Action{
                   type: :search_deck_to_hand,
                   player_id: player_id,
                   params: %{instance_id: card.instance_id}
                 })

        {:ok, state, card_in_hand(state, player_id, card_id)}

      true ->
        {:skip, state}
    end
  end

  defp exercise_card_from_hand(state, player_id, card) do
    metadata = CardRegistry.fetch!(card.card_id)

    cond do
      metadata[:supertype] == :energy && !state.players[player_id].energy_attached? ->
        Engine.apply_action(state, %Action{
          type: :attach_energy,
          player_id: player_id,
          params: %{
            instance_id: card.instance_id,
            target_id: state.players[player_id].active.instance_id
          }
        })

      metadata[:supertype] == :pokemon && metadata[:stage] == :basic &&
          length(state.players[player_id].bench) < 5 ->
        Engine.apply_action(state, %Action{
          type: :play_basic_to_bench,
          player_id: player_id,
          params: %{instance_id: card.instance_id}
        })

      metadata[:supertype] == :pokemon && Map.has_key?(metadata, :evolves_from) ->
        evolve_or_discard(state, player_id, card, metadata)

      metadata[:trainer_type] == :stadium ->
        Engine.apply_action(state, %Action{
          type: :play_stadium,
          player_id: player_id,
          params: %{instance_id: card.instance_id}
        })

      metadata[:trainer_type] == :tool && is_nil(state.players[player_id].active.tool) ->
        Engine.apply_action(state, %Action{
          type: :attach_tool,
          player_id: player_id,
          params: %{
            instance_id: card.instance_id,
            target_id: state.players[player_id].active.instance_id
          }
        })

      metadata[:supertype] == :trainer && metadata[:trainer_type] != :supporter ->
        Engine.apply_action(state, %Action{
          type: :play_trainer_to_discard,
          player_id: player_id,
          params: %{instance_id: card.instance_id}
        })

      metadata[:supertype] == :trainer && !state.players[player_id].supporter_played? ->
        Engine.apply_action(state, %Action{
          type: :play_trainer_to_discard,
          player_id: player_id,
          params: %{instance_id: card.instance_id}
        })

      true ->
        Engine.apply_action(state, %Action{
          type: :discard_from_hand,
          player_id: player_id,
          params: %{instance_id: card.instance_id}
        })
    end
  end

  defp evolve_or_discard(state, player_id, card, metadata) do
    target =
      Enum.find(
        [state.players[player_id].active | state.players[player_id].bench],
        &(&1 && &1.card_id == metadata.evolves_from)
      )

    if target do
      case Engine.apply_action(state, %Action{
             type: :evolve_from_hand,
             player_id: player_id,
             params: %{instance_id: card.instance_id, target_id: target.instance_id}
           }) do
        {:ok, state} ->
          {:ok, state}

        {:error, reason}
        when reason in [
               :cannot_evolve_pokemon_played_this_turn,
               :cannot_evolve_on_first_turn_of_game
             ] ->
          discard_from_hand(state, player_id, card)
      end
    else
      discard_from_hand(state, player_id, card)
    end
  end

  defp discard_from_hand(state, player_id, card) do
    Engine.apply_action(state, %Action{
      type: :discard_from_hand,
      player_id: player_id,
      params: %{instance_id: card.instance_id}
    })
  end

  defp setup_game(opts) do
    active_player = Keyword.fetch!(opts, :active_player)
    alakazam_bench? = Keyword.get(opts, :alakazam_bench?, false)

    dragapult_opening = [
      "TWM-128",
      "ASC-016",
      "MEE-005",
      "MEE-002",
      "MEE-007",
      "MEG-119",
      "TEF-144"
    ]

    alakazam_opening = [
      "MEG-054",
      "JTG-120",
      "POR-088",
      "MEG-055",
      "MEG-056",
      "PFL-087",
      "TEF-144"
    ]

    state =
      Engine.new_game(
        active_player: active_player,
        players: [
          dragapult:
            deck_with_prefix(
              dragapult_opening ++
                ["TWM-128", "TWM-128", "TWM-129", "TWM-129", "TWM-130", "MEG-119"],
              Dragapult27431.card_ids()
            ),
          alakazam:
            deck_with_prefix(
              alakazam_opening ++
                ["MEG-054", "MEG-054", "MEG-055", "MEG-055", "TEF-129", "PFL-087"],
              Alakazam27147.card_ids()
            )
        ]
      )

    with {:ok, state} <- Engine.apply_action(state, %Action{type: :start_setup}),
         {:ok, state} <- Engine.apply_action(state, %Action{type: :draw_opening_hand}),
         {:ok, state} <- choose_active(state, :dragapult, "TWM-128"),
         {:ok, state} <- choose_active(state, :alakazam, "MEG-054"),
         {:ok, state} <- maybe_setup_bench(state, alakazam_bench?),
         {:ok, state} <- Engine.apply_action(state, %Action{type: :place_prizes}) do
      Engine.apply_action(state, %Action{type: :complete_setup})
    end
  end

  defp open_turn(state, player_id) do
    with {:ok, state} <-
           Engine.apply_action(state, %Action{type: :draw_for_turn, player_id: player_id}) do
      Engine.apply_action(state, %Action{type: :open_action_window})
    end
  end

  defp search_to_hand_by_card_id(state, player_id, card_id) do
    card = card_in_deck(state, player_id, card_id)

    with {:ok, state} <-
           Engine.apply_action(state, %Action{
             type: :search_deck_to_hand,
             player_id: player_id,
             params: %{instance_id: card.instance_id}
           }) do
      {:ok, state, card_in_hand(state, player_id, card_id)}
    end
  end

  defp maybe_setup_bench(state, false), do: {:ok, state}
  defp maybe_setup_bench(state, true), do: choose_setup_bench(state, :alakazam, "JTG-120")

  defp choose_active(state, player_id, card_id) do
    card = card_in_hand(state, player_id, card_id)

    Engine.apply_action(state, %Action{
      type: :choose_active_from_hand,
      player_id: player_id,
      params: %{instance_id: card.instance_id}
    })
  end

  defp choose_setup_bench(state, player_id, card_id) do
    card = card_in_hand(state, player_id, card_id)

    Engine.apply_action(state, %Action{
      type: :choose_setup_bench_from_hand,
      player_id: player_id,
      params: %{instance_id: card.instance_id}
    })
  end

  defp scripted_attack(state, attacking_player_id, defending_player_id, target_id, damage) do
    with {:ok, state} <-
           Engine.apply_action(state, %Action{
             type: :draw_for_turn,
             player_id: attacking_player_id
           }),
         {:ok, state} <- Engine.apply_action(state, %Action{type: :open_action_window}),
         {:ok, state} <-
           Engine.apply_action(state, %Action{
             type: :declare_attack,
             player_id: attacking_player_id
           }) do
      Engine.apply_action(state, %Action{
        type: :resolve_attack_damage,
        player_id: attacking_player_id,
        params: %{target_player_id: defending_player_id, target_id: target_id, damage: damage}
      })
    end
  end

  defp pass_turn(state, player_id) do
    with {:ok, state} <-
           Engine.apply_action(state, %Action{type: :draw_for_turn, player_id: player_id}),
         {:ok, state} <- Engine.apply_action(state, %Action{type: :open_action_window}),
         {:ok, state} <-
           Engine.apply_action(state, %Action{type: :end_turn, player_id: player_id}) do
      Engine.apply_action(state, %Action{type: :start_next_turn})
    end
  end

  defp card_in_hand(state, player_id, card_id),
    do: Enum.find(state.players[player_id].hand, &(&1.card_id == card_id))

  defp card_in_deck(state, player_id, card_id),
    do: Enum.find(state.players[player_id].deck, &(&1.card_id == card_id))

  defp pokemon_in_deck_by_stage(state, player_id, stage) do
    Enum.find(state.players[player_id].deck, fn card ->
      metadata = CardRegistry.fetch!(card.card_id)
      metadata[:supertype] == :pokemon && metadata[:stage] == stage
    end)
  end

  defp deck_with_prefix(prefix, full_deck_ids) do
    remainder = Enum.reduce(prefix, full_deck_ids, &remove_one/2)
    prefix ++ remainder
  end

  defp remove_one(card_id, card_ids) do
    {before_match, [_match | after_match]} = Enum.split_while(card_ids, &(&1 != card_id))
    before_match ++ after_match
  end
end
