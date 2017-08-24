defmodule PlayingAGameTest do
  use ExUnit.Case, async: true

  @tag :pending
  test "playing a round with three players" do
    deck = Humanity.DeckBuilder.create(name: "Deck", decks: [Humanity.Decks.Default])
    game = Humanity.init(deck: deck)
    game = Humanity.add_player(game, id: 1, name: "Richard")
    game = Humanity.add_player(game, id: 2, name: "Storm")
    game = Humanity.add_player(game, id: 3, name: "Joe")
    game = Humanity.start(game)

    first_card_czar = game.current_card_czar_id
    game = Humanity.announce_black_card(game)

    game = Enum.reduce(game.current_entrants, game, fn(entrant, game) ->
        Humanity.enter_white_cards(game, entrant, List.first(entrant.hand))
    end)

    entries = Humanity.current_entries(game)
    game = Humanity.pick_winning_white_card(game, List.first(entries))
    winning_entry = Humanity.winning_entries(game) |> List.first
    winning_player = winning_entry.player
    expected_scores = Map.merge(%{"richard" => 0, "storm" => 0, "joe" => 0}, %{winning_player.name => 1})

    assert game.current_card_czar_id != first_card_czar
    assert Humanity.scores(game) == expected_scores
    assert Humanity.game_finished?(game) == false
  end
end
