defmodule OrderBookTest do
  use ExUnit.Case

  describe "#add_bid" do
    test "adds new bid" do
      order_book = OrderBook.new() |> OrderBook.add_bid(1, 50, 30)
      assert order_book == %OrderBook{bid: %{1 => [{50, 30}]}}
    end

    test "adds new bid at the top for the given level" do
      order_book = OrderBook.new() |> OrderBook.add_bid(1, 50, 30) |> OrderBook.add_bid(1, 50, 40)
      assert order_book == %OrderBook{bid: %{1 => [{50, 40}, {50, 30}]}}
    end
  end

  describe "#add_ask" do
    test "adds new ask" do
      order_book = OrderBook.new() |> OrderBook.add_ask(1, 50, 30)
      assert order_book == %OrderBook{ask: %{1 => [{50, 30}]}}
    end

    test "adds new ask at the top for the given level" do
      order_book = OrderBook.new() |> OrderBook.add_ask(1, 50, 30) |> OrderBook.add_ask(1, 50, 40)
      assert order_book == %OrderBook{ask: %{1 => [{50, 40}, {50, 30}]}}
    end
  end

  describe "#delete_bid" do
    test "deletes existing bid" do
      order_book = OrderBook.new() |> OrderBook.add_bid(1, 50, 30) |> OrderBook.delete_bid(1, 50)
      assert order_book == %OrderBook{bid: %{1 => []}}
    end

    test "deletes existing bids" do
      order_book =
        OrderBook.new()
        |> OrderBook.add_bid(1, 50, 30)
        |> OrderBook.add_bid(1, 50, 40)
        |> OrderBook.delete_bid(1, 50)

      assert order_book == %OrderBook{bid: %{1 => []}}
    end

    test "deletes existing bid, preserving other levels" do
      order_book =
        OrderBook.new()
        |> OrderBook.add_bid(1, 50, 30)
        |> OrderBook.add_bid(2, 50, 40)
        |> OrderBook.delete_bid(1, 50)

      assert order_book == %OrderBook{bid: %{1 => [], 2 => [{50, 40}]}}
    end
  end

  describe "#delete_ask" do
    test "deletes existing ask" do
      order_book = OrderBook.new() |> OrderBook.add_ask(1, 50, 30) |> OrderBook.delete_ask(1, 50)
      assert order_book == %OrderBook{ask: %{1 => []}}
    end

    test "deletes existing asks" do
      order_book =
        OrderBook.new()
        |> OrderBook.add_ask(1, 50, 30)
        |> OrderBook.add_ask(1, 50, 40)
        |> OrderBook.delete_ask(1, 50)

      assert order_book == %OrderBook{ask: %{1 => []}}
    end

    test "deletes existing ask, preserving other levels" do
      order_book =
        OrderBook.new()
        |> OrderBook.add_ask(1, 50, 30)
        |> OrderBook.add_ask(2, 50, 40)
        |> OrderBook.delete_ask(1, 50)

      assert order_book == %OrderBook{ask: %{1 => [], 2 => [{50, 40}]}}
    end
  end

  describe "#update_bid" do
    test "updates existing bid" do
      order_book =
        OrderBook.new()
        |> OrderBook.add_bid(1, 50, 30)
        |> OrderBook.add_bid(2, 50, 30)
        |> OrderBook.update_bid(1, 50, 40)

      assert order_book == %OrderBook{bid: %{1 => [{50, 40}], 2 => [{50, 30}]}}
    end

    test "raises error when price level not found" do
      assert OrderBook.new() |> OrderBook.update_bid(1, 50, 40) ==
               {:error, :price_level_not_found}
    end
  end

  describe "#update_ask" do
    test "updates existing ask" do
      order_book =
        OrderBook.new()
        |> OrderBook.add_ask(1, 50, 30)
        |> OrderBook.add_ask(2, 50, 30)
        |> OrderBook.update_ask(1, 50, 40)

      assert order_book == %OrderBook{ask: %{1 => [{50, 40}], 2 => [{50, 30}]}}
    end

    test "returns error when price level not found" do
      assert OrderBook.new() |> OrderBook.update_ask(1, 50, 40) ==
               {:error, :price_level_not_found}
    end
  end
end
