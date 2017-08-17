defmodule HumanityTest do
  use ExUnit.Case, async: true

  describe "creating a new game" do
    setup do
      {:ok, game} = Humanity.init(
        players: ["Dana"],
        white_cards: [1, 2, 3, 4, 5],
        black_cards: ["a", "b", "c", "d", "e"]
      )

      %{game: game}
    end

    test "creates players", %{game: game} do
      assert List.first(game.players) == %Humanity.Player{name: "Dana", hand: []}
    end

    test "creates a white deck", %{game: game} do
      assert Enum.sort(game.white_deck) == [1, 2, 3, 4, 5]
    end

    test "creates a black deck", %{game: game} do
      assert Enum.sort(game.black_deck) == ["a", "b", "c", "d", "e"]
    end

    test "shuffles the decks", %{game: game} do
      {:ok, dup_game} = Humanity.init(
        players: ["Dana"],
        white_cards: [1, 2, 3, 4, 5],
        black_cards: ["a", "b", "c", "d", "e"]
      )

      assert game.white_deck != dup_game.white_deck
      assert game.black_deck != dup_game.black_deck
    end

    test "marks the game as ready", %{game: game} do
      assert game.state == :ready
    end
  end

  describe "dealing cards" do
    setup do
      {:ok, game} = Humanity.init(players: ["Dana", "Fox"], white_cards: [], black_cards: ["a", "b", "c", "d", "e"])
      {:ok, game} = Humanity.deal_cards(game)

      %{game: game}
    end

    test "deals cards to each player", %{game: game} do
      assert Enum.map(game.players, &(&1.name)) == ["Dana", "Fox"]
      assert Enum.flat_map(game.players, &(&1.hand)) |> Enum.count == 4
    end

    test "removes dealt cards from the black deck", %{game: game} do
      assert Enum.count(game.black_deck) == 1
    end

    test "deals unique cards to each player", %{game: game} do
      players_cards = game.players |> Enum.flat_map(&(&1.hand))
      remaining_deck = game.black_deck

      assert Enum.concat(players_cards, remaining_deck) |> Enum.uniq |> Enum.count == 5
    end
  end
end
