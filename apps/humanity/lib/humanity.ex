defmodule Humanity do
  defmodule GameState do
    defstruct [:white_deck, :black_deck, :players, :state]
  end

  defmodule Player do
    defstruct [:name, :hand]
  end

  def init(players: players, white_cards: white_cards, black_cards: black_cards) do
    game = %GameState{
      white_deck: create_deck(white_cards),
      black_deck: create_deck(black_cards),
      players: Enum.map(players, &(create_player(name: &1))),
      state: :ready
    }

    {:ok, game}
  end

  def deal_cards(game_state) do
    {new_players, new_black_deck} = Enum.reduce(game_state.players, {[], game_state.black_deck}, fn (player, {new_players, new_black_deck}) ->
      {new_player, new_black_deck} = fill_hand(player, new_black_deck)
      new_players = Enum.concat(new_players, [new_player])
      {new_players, new_black_deck}
    end)

    new_state = %GameState{game_state | players: new_players, black_deck: new_black_deck}

    {:ok, new_state}
  end

  defp fill_hand(player, black_cards) do
    num_required_cards = 2
    num_player_cards = Enum.count(player.hand)
    num_remaining_cards = num_required_cards - num_player_cards

    new_player_cards = Enum.take(black_cards, num_remaining_cards)
    new_black_cards = Enum.drop(black_cards, num_remaining_cards)
    new_hand = Enum.concat(player.hand, new_player_cards)

    {%Player{player | hand: new_hand}, new_black_cards}
  end

  defp create_deck(cards) do
    Enum.shuffle(cards)
  end

  defp create_player(name: name) do
    %Player{
      name: name,
      hand: []
    }
  end
end
