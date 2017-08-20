defmodule Humanity.DeckBuilderTest do
  use ExUnit.Case, async: true

  defmodule DeckA do
    def black_cards, do: ["My favourite fruit", "My worst fruit"]
    def white_cards, do: ["Apple", "Orange", "Pear"]
  end

  defmodule DeckB do
    def black_cards, do: ["My favourite friend", "My worst friend"]
    def white_cards, do: ["Tom", "Dick", "Harry"]
  end

  setup do
    deck = Humanity.DeckBuilder.create(name: "My Custom Test Deck", decks: [DeckA, DeckB])
    %{deck: deck}
  end

  test "it should have a name", %{deck: deck} do
    assert deck.name == "My Custom Test Deck"
  end

  test "it should create a deck all the black cards of the decks given", %{deck: deck} do
    assert deck.black_cards == [
      "My favourite fruit",
      "My worst fruit",
      "My favourite friend",
      "My worst friend"
    ]
  end

  test "it should create a deck all the white cards of the decks given", %{deck: deck} do
    assert deck.white_cards == [
      "Apple",
      "Orange",
      "Pear",
      "Tom",
      "Dick",
      "Harry"
    ]
  end
end
