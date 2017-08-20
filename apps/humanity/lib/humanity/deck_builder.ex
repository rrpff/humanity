defmodule Humanity.DeckBuilder do
  def create(name: name, decks: decks) do
    %Humanity.Deck{
      name: name,
      black_cards: Enum.flat_map(decks, &(&1.black_cards)),
      white_cards: Enum.flat_map(decks, &(&1.white_cards))
    }
  end
end
