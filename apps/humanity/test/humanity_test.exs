defmodule HumanityTest do
  use ExUnit.Case, async: true

  describe "creating a new game" do
    setup do
      deck = %Humanity.Deck{
        black_cards: ["My favourite fruit", "My worst fruit", "My favourite friend", "My worst friend"],
        white_cards: ["Apple", "Orange", "Pear", "Tom", "Dick", "Harry"]
      }

      game = Humanity.init(deck: deck)

      %{deck: deck, game: game}
    end

    test "creates a white deck", %{game: game} do
      assert Enum.sort(game.white_deck) == ["Apple", "Dick", "Harry", "Orange", "Pear", "Tom"]
    end

    test "creates a black deck", %{game: game} do
      assert Enum.sort(game.black_deck) == ["My favourite friend", "My favourite fruit", "My worst friend", "My worst fruit"]
    end

    test "shuffles the white deck", %{deck: deck} do
      shuffle_results = for _ <- 1..5, do: Humanity.init(deck: deck).white_deck
      assert Enum.uniq(shuffle_results) |> Enum.count > 1
    end

    test "shuffles the black deck", %{deck: deck} do
      shuffle_results = for _ <- 1..5, do: Humanity.init(deck: deck).black_deck
      assert Enum.uniq(shuffle_results) |> Enum.count > 1
    end

    test "marks the game as setup", %{game: game} do
      assert game.state == :setup
    end

    test "can add players to the game", %{game: game} do
      game = Humanity.add_player(game, id: :whatever, name: "Stormy")
      assert game.players == [%Humanity.Player{id: :whatever, name: "Stormy", hand: []}]
    end
  end

  describe "starting the game" do
    setup do
      deck = Humanity.DeckBuilder.create(name: "deck", decks: [Humanity.Decks.Default])
      initial_game = Humanity.init(deck: deck)
      game = Humanity.add_player(initial_game, id: 1, name: "Dana")
      game = Humanity.add_player(game, id: 2, name: "Fox")
      game = Humanity.add_player(game, id: 3, name: "Skinner")
      game = Humanity.start(game)

      %{initial_game: initial_game, game: game}
    end

    test "deals 10 cards to each player", %{game: game} do
      Enum.each game.players, fn (player) ->
        assert Enum.count(player.hand) == 10
      end
    end

    test "removes dealt cards from the white deck", %{initial_game: initial_game, game: game} do
      assert Enum.count(initial_game.white_deck) - Enum.count(game.white_deck) == 30
    end

    test "deals unique cards to each player", %{initial_game: initial_game, game: game} do
      num_cards_in_play = game.players |> Enum.flat_map(&(&1.hand)) |> Enum.concat(game.white_deck) |> Enum.count

      assert num_cards_in_play == Enum.count(initial_game.white_deck)
    end

    test "assigns a current card czar", %{game: game} do
      current_card_czar_name = Humanity.current_card_czar(game).name
      assert Enum.member?(["Dana", "Fox", "Skinner"], current_card_czar_name)
    end

    test "assigns current entrants", %{game: game} do
      current_entrant_names = Humanity.current_entrants(game) |> Enum.map(&(&1.name))
      assert Enum.member?(["Dana", "Fox", "Skinner"], List.first(current_entrant_names))
      assert Enum.count(current_entrant_names) == 2
    end

    test "sets the game state as round", %{game: game} do
      assert game.state == :round
    end
  end

  describe "playing a game" do
    setup do
      deck = Humanity.DeckBuilder.create(name: "deck", decks: [Humanity.Decks.Default])
      game = Humanity.init(deck: deck)
      game = Humanity.add_player(game, id: 1, name: "Dana")
      game = Humanity.add_player(game, id: 2, name: "Fox")
      game = Humanity.add_player(game, id: 3, name: "Skinner")
      game = Humanity.start(game)

      %{game: game}
    end

    test "announcing a card sets the current black card for the round from the top of the black deck", %{game: game} do
      expected_black_card = List.first(game.black_deck)
      game = Humanity.announce_black_card(game)
      assert game.current_black_card == expected_black_card
    end

    test "entering a white card should add to the pool of white cards", %{game: game} do
      entrant = List.first(Humanity.current_entrants(game))
      [white_card|_] = entrant.hand
      game = Humanity.enter_white_cards(game, entrant, [white_card])

      assert game.current_entries == [
        %Humanity.Entry{entrant: entrant, cards: [white_card]}
      ]
    end

    test "entering a white card should raise an error if the player has already played", %{game: game} do
      entrant = List.first(Humanity.current_entrants(game))
      first_white_card = Enum.at(entrant.hand, 0)
      second_white_card = Enum.at(entrant.hand, 1)
      game = Humanity.enter_white_cards(game, entrant, first_white_card)

      assert_raise(RuntimeError, "Player has already entered this round", fn ->
        Humanity.enter_white_cards(game, entrant, second_white_card)
      end)
    end
  end
end
