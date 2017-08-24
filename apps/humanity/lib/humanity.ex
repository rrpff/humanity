defmodule Humanity do
  defmodule Game do
    defstruct [:white_deck, :black_deck, :players, :state, :current_card_czar_id, :current_black_card, :current_entries]
  end

  defmodule Player do
    defstruct [:id, :name, :hand]
  end

  defmodule Deck do
    defstruct [:name, :black_cards, :white_cards]
  end

  defmodule Entry do
    defstruct [:entrant, :cards]
  end

  defmodule Dealer do
    @card_limit 10

    def deal(cards, players, current_player_index \\ 0) do
      cond do
        Enum.empty?(cards) ->
          {cards, players}
        Enum.all?(players, &has_enough_cards?/1) ->
          {cards, players}
        true ->
          player = Enum.at(players, current_player_index)
          {new_cards, new_player} = deal_to_player(cards, player)
          new_players = List.replace_at(players, current_player_index, new_player)
          next_player_index = next_index(players, current_player_index)
          deal(new_cards, new_players, next_player_index)
      end
    end

    defp deal_to_player(cards, player) do
      if has_enough_cards?(player) do
        {cards, player}
      else
        [drawn_card|remaining_cards] = cards
        new_hand = [drawn_card|player.hand]
        new_player = %Player{player|hand: new_hand}
        {remaining_cards, new_player}
      end
    end

    defp has_enough_cards?(player) do
      Enum.count(player.hand) == @card_limit
    end

    defp next_index(list, current_index) do
      if current_index + 1 == Enum.count(list), do: 0, else: current_index + 1
    end
  end

  def init(deck: deck) do
    %Game{
      white_deck: Enum.shuffle(deck.white_cards),
      black_deck: Enum.shuffle(deck.black_cards),
      players: [],
      state: :setup,
      current_card_czar_id: nil,
      current_black_card: nil,
      current_entries: nil
    }
  end

  def add_player(game, id: id, name: name) do
    new_player = %Player{id: id, name: name, hand: []}
    new_players = [new_player | game.players]
    %Game{game | players: new_players}
  end

  def start(game) do
    {new_white_deck, new_players} = Dealer.deal(game.white_deck, game.players, 0)
    initial_card_czar = next_card_czar(game)
    %Game{game |
      white_deck: new_white_deck,
      players: new_players,
      current_card_czar_id: initial_card_czar.id,
      state: :round,
      current_entries: []
    }
  end

  def announce_black_card(game) do
    [current_black_card|remaining_black_deck] = game.black_deck
    %Game{game | current_black_card: current_black_card, black_deck: remaining_black_deck}
  end

  def enter_white_cards(game, entrant, cards) do
    if entrant_has_entered_round?(game, entrant) do
      raise RuntimeError, "Player has already entered this round"
    end

    new_entry = %Entry{entrant: entrant, cards: cards}
    %Game{game | current_entries: [new_entry | game.current_entries]}
  end

  def current_card_czar(%Game{current_card_czar_id: nil}), do: nil
  def current_card_czar(game) do
    Enum.find(game.players, &(&1.id == game.current_card_czar_id))
  end

  def current_entrants(%Game{current_card_czar_id: nil}), do: []
  def current_entrants(game) do
    Enum.filter(game.players, &(&1.id != game.current_card_czar_id))
  end

  defp next_card_czar(%Game{current_card_czar_id: nil} = game), do: List.first(game.players)
  defp next_card_czar(game) do
    current_card_czar_index = Enum.find_index(game.players, current_card_czar(game))
    next_card_czar_index = next_index(game.players, current_card_czar_index)

    Enum.at(game.players, next_card_czar_index)
  end

  defp next_index(list, current_index) do
    if current_index + 1 == Enum.count(list), do: 0, else: current_index + 1
  end

  defp entrant_has_entered_round?(game, entrant) do
    Enum.any?(game.current_entries, &(&1.entrant.id == entrant.id))
  end
end
