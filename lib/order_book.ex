defmodule OrderBook do
  defstruct bid: Map.new(), ask: Map.new()

  def new, do: %OrderBook{}

  def add_bid(%OrderBook{bid: bid} = order_book, price_level_index, price, quantity) do
    %OrderBook{order_book | bid: add_price_level(bid, price_level_index, price, quantity)}
  end

  def add_ask(%OrderBook{ask: ask} = order_book, price_level_index, price, quantity) do
    %OrderBook{order_book | ask: add_price_level(ask, price_level_index, price, quantity)}
  end

  def delete_bid(%OrderBook{bid: bid} = order_book, price_level_index, price) do
    %OrderBook{order_book | bid: delete_price_level(bid, price_level_index, price)}
  end

  def delete_ask(%OrderBook{ask: ask} = order_book, price_level_index, price) do
    %OrderBook{order_book | ask: delete_price_level(ask, price_level_index, price)}
  end

  def update_bid(%OrderBook{bid: bid} = order_book, price_level_index, price, quantity) do
    case update_price_level(bid, price_level_index, price, quantity) do
      {:error, _} = error -> error
      updated_prices -> %OrderBook{order_book | bid: updated_prices}
    end
  end

  def update_ask(%OrderBook{ask: ask} = order_book, price_level_index, price, quantity) do
    case update_price_level(ask, price_level_index, price, quantity) do
      {:error, _} = error -> error
      updated_prices -> %OrderBook{order_book | ask: updated_prices}
    end
  end

  def order(%OrderBook{ask: ask, bid: bid}, book_depth) do
    latest_bids_by_level =
      latest_prices_by_level(bid, book_depth)
      |> Enum.map(fn {l, {p, q}} -> {l, %{bid_price: p, bid_quantity: q}} end)
      |> Map.new()

    latest_asks_by_level =
      latest_prices_by_level(ask, book_depth)
      |> Enum.map(fn {l, {p, q}} -> {l, %{ask_price: p, ask_quantity: q}} end)
      |> Map.new()

    latest_asks_by_level
    |> Map.merge(latest_bids_by_level, fn _, ask, bid -> Map.merge(ask, bid) end)
    |> Map.values()
  end

  defp latest_prices_by_level(price_levels, book_depth) do
    price_levels
    |> Enum.reject(fn {level, prices} -> level > book_depth or Enum.empty?(prices) end)
    |> Enum.map(fn {level, [latest | _]} -> {level, latest} end)
  end

  defp add_price_level(price_levels, price_level_index, price, quantity) do
    prices = Map.get(price_levels, price_level_index, [])
    Map.put(price_levels, price_level_index, [{price, quantity} | prices])
  end

  # Deletes all existing prices for the given level
  defp delete_price_level(price_levels, price_level_index, price) do
    prices = Map.get(price_levels, price_level_index, [])
    Map.put(price_levels, price_level_index, Enum.reject(prices, fn {p, _} -> p == price end))
  end

  # Updates all existing prices for the given level with the new quantatity
  defp update_price_level(price_levels, price_level_index, price, quantity) do
    case Map.get(price_levels, price_level_index) do
      nil ->
        {:error, :price_level_not_found}

      prices ->
        updated_prices =
          prices
          |> Enum.map(fn
            {^price, _} -> {price, quantity}
            other -> other
          end)

        Map.put(price_levels, price_level_index, updated_prices)
    end
  end
end
