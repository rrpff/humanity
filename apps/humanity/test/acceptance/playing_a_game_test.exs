defmodule PlayingAGameTest do
  use ExUnit.Case, async: true

  test "playing a round with three players" do
    game = Humanity.init(white_cards: [], black_cards: [])
    |> Humanity.add_player(name: "richard")
    |> Humanity.add_player(name: "storm")
    |> Humanity.add_player(name: "joe")
    |> Humanity.deal_gards

    first_card_czar = Humanity.current_card_czar(game)
    round_entrants = Humanity.current_entrants(game)
    game = Humanity.announce_black_card(game, List.first(first_card_czar.hand))

    game = Enum.reduce(round_entrants, game, fn(entrant, game) ->
      Humanity.enter_white_card(game, entrant, List.first(entrant.hand))
    end)

    entries = Humanity.current_entries(game)
    game = Humanity.pick_winning_white_card(game, List.first(entries))
    winning_entry = Humanity.winning_entries(game) |> List.first
    winning_player = winning_entry.player
    expected_scores = Map.merge(%{"richard" => 0, "storm" => 0, "joe" => 0}, %{winning_player.name => 1})

    assert Humanity.current_card_czar(game) != first_card_czar
    assert Humanity.scores(game) == expected_scores
    assert Humanity.game_finished?(game) == false
  end
end
