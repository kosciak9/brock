defmodule Mix.Tasks.BattleLogs.Parse do
  @shortdoc "Parses PTCGL battle logs into JSON"

  @moduledoc """
  Parses plain-text Pokémon TCG Live battle logs into coarse JSON.

      mix battle_logs.parse
      mix battle_logs.parse --input knowledge-base/battle-logs --output knowledge-base/battle-logs/parsed
      mix battle_logs.parse knowledge-base/battle-logs/20260526203320.md

  The output intentionally follows the lightweight shape of the selected
  `parseGameLog` parser candidate: setup lines, turn/action groups, detected
  players, result, and the raw log.
  """

  use Mix.Task

  @default_input_dir "knowledge-base/battle-logs"
  @default_output_dir "knowledge-base/battle-logs/parsed"

  @impl Mix.Task
  def run(args) do
    {input_path, output_dir} = parse_args!(args)
    files = input_files!(input_path)

    File.mkdir_p!(output_dir)

    Enum.each(files, fn source_path ->
      text = File.read!(source_path)
      parsed = parse_game_log(text, source_path)
      output_path = output_path(source_path, output_dir)

      File.write!(output_path, Jason.encode!(parsed, pretty: true) <> "\n")

      Mix.shell().info(
        "Parsed #{source_path} -> #{output_path} " <>
          "(#{length(parsed["turns"])} turns, result: #{parsed["result"]})"
      )
    end)
  end

  defp parse_args!(args) do
    {opts, positional} = OptionParser.parse!(args, strict: [input: :string, output: :string])

    input_path = Keyword.get(opts, :input) || Enum.at(positional, 0) || @default_input_dir
    output_dir = Keyword.get(opts, :output) || Enum.at(positional, 1) || @default_output_dir

    {input_path, output_dir}
  end

  defp input_files!(input_path) do
    files =
      cond do
        File.dir?(input_path) ->
          input_path
          |> Path.join("*.md")
          |> Path.wildcard()
          |> Enum.sort()

        File.regular?(input_path) ->
          [input_path]

        true ->
          Mix.raise("Battle log input not found: #{input_path}")
      end

    if files == [] do
      Mix.raise("No .md battle logs found in #{input_path}")
    end

    files
  end

  defp output_path(source_path, output_dir) do
    stem = source_path |> Path.basename() |> Path.rootname()
    Path.join(output_dir, stem <> ".json")
  end

  defp parse_game_log(text, source_path) do
    normalized_text = String.replace(text, "\r\n", "\n")
    lines = String.split(normalized_text, "\n")

    player_names = detect_players(lines)
    player_name = detect_user_player(lines, player_names)
    opponent_name = Enum.find(player_names, &(&1 != player_name)) || "Unknown"
    winner = detect_winner(lines)
    result = detect_result(winner, player_name)
    {setup, turns} = split_into_turns(lines, player_names)

    %{
      "id" => "match-#{source_path |> Path.basename() |> Path.rootname()}",
      "sourceFile" => source_path,
      "sourceTimestamp" => source_timestamp(source_path),
      "playerName" => player_name,
      "opponentName" => opponent_name,
      "winner" => winner || "Unknown",
      "result" => result,
      "setup" => setup,
      "turns" => turns,
      "rawLog" => normalized_text
    }
  end

  defp detect_players(lines) do
    Enum.reduce(lines, [], fn line, players ->
      players
      |> add_action_player(line)
      |> add_turn_player(line)
    end)
  end

  defp add_action_player(players, line) do
    case Regex.run(
           ~r/^(\S+)\s+(drew|played|chose|won|decided|took|ended|evolved|attached|retreated|conceded)/,
           line
         ) do
      [_, player, _action] -> add_player(players, player)
      _ -> players
    end
  end

  defp add_turn_player(players, line) do
    case Regex.run(~r/^(.+)['’]s Turn$/, String.trim(line)) do
      [_, player] -> add_player(players, player)
      _ -> players
    end
  end

  defp add_player(players, player) when player in ["Opponent", "Setup", "You", "A"] do
    players
  end

  defp add_player(players, player) do
    if player in players do
      players
    else
      players ++ [player]
    end
  end

  defp detect_user_player(lines, player_names) do
    Enum.find_value(Enum.with_index(lines), List.first(player_names, "Unknown"), fn {line, index} ->
      case Regex.run(~r/^(\S+) drew \d+ cards for the opening hand/, line) do
        [_, player] ->
          next_line = lines |> Enum.at(index + 1, "") |> String.trim()
          following_line = lines |> Enum.at(index + 2, "") |> String.trim()

          if String.starts_with?(next_line, "- ") and String.starts_with?(following_line, "•") do
            player
          end

        _ ->
          nil
      end
    end)
  end

  defp detect_winner(lines) do
    lines
    |> Enum.reverse()
    |> Enum.find_value(fn line ->
      case Regex.run(~r/(\S+) wins\.?$/, String.trim(line)) do
        [_, winner] -> winner
        _ -> nil
      end
    end)
  end

  defp detect_result(nil, _player_name), do: "unknown"
  defp detect_result(winner, player_name) when winner == player_name, do: "win"
  defp detect_result(_winner, _player_name), do: "loss"

  defp split_into_turns(lines, player_names) do
    {setup, turns, current_turn, _in_setup} =
      Enum.reduce(lines, {[], [], nil, true}, fn line, {setup, turns, current_turn, in_setup} ->
        trimmed = String.trim(line)

        cond do
          trimmed == "" ->
            {setup, turns, current_turn, in_setup}

          turn_player = turn_player(trimmed, player_names) ->
            turns = append_current_turn(turns, current_turn)

            current_turn = %{
              "turnNumber" => length(turns) + 1,
              "player" => turn_player,
              "actions" => []
            }

            {setup, turns, current_turn, false}

          in_setup ->
            {setup ++ [trimmed], turns, current_turn, in_setup}

          current_turn ->
            current_turn = update_in(current_turn, ["actions"], &(&1 ++ [trimmed]))
            {setup, turns, current_turn, in_setup}
        end
      end)

    {setup, append_current_turn(turns, current_turn)}
  end

  defp turn_player(line, player_names) do
    case Regex.run(~r/^(.+)['’]s Turn$/, line) do
      [_, player] ->
        if player_names == [] or player in player_names do
          player
        end

      _ ->
        nil
    end
  end

  defp append_current_turn(turns, nil), do: turns
  defp append_current_turn(turns, current_turn), do: turns ++ [current_turn]

  defp source_timestamp(source_path) do
    stem = source_path |> Path.basename() |> Path.rootname()

    case Regex.run(~r/^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$/, stem) do
      [_, year, month, day, hour, minute, second] ->
        "#{year}-#{month}-#{day}T#{hour}:#{minute}:#{second}"

      _ ->
        nil
    end
  end
end
