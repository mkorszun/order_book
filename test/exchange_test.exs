defmodule ExchangeTest do
  use ExUnit.Case

  describe "Exchange" do
    setup do
      {:ok, pid} = Exchange.start_link()
      {:ok, %{exchange_pid: pid}}
    end

    test "should return empty order book", %{
      exchange_pid: exchange_pid
    } do
      assert Exchange.order_book(exchange_pid, 2) == []
    end

    test "should return empty order book when price levels below specified depth", %{
      exchange_pid: exchange_pid
    } do
      instruction = %{
        instruction: :new,
        side: :ask,
        price_level_index: 3,
        price: 50.0,
        quantity: 30
      }

      :ok = Exchange.send_instruction(exchange_pid, instruction)

      assert Exchange.order_book(exchange_pid, 2) == []
    end

    test "should return empty order book after deletions", %{
      exchange_pid: exchange_pid
    } do
      instruction = %{
        instruction: :new,
        side: :ask,
        price_level_index: 1,
        price: 50.0,
        quantity: 30
      }

      :ok = Exchange.send_instruction(exchange_pid, instruction)
      :ok = Exchange.send_instruction(exchange_pid, instruction |> Map.put(:instruction, :delete))

      assert Exchange.order_book(exchange_pid, 2) == []
    end

    test "should return order without bids", %{
      exchange_pid: exchange_pid
    } do
      instruction = %{
        instruction: :new,
        side: :ask,
        price_level_index: 1,
        price: 50.0,
        quantity: 30
      }

      :ok = Exchange.send_instruction(exchange_pid, instruction)

      assert Exchange.order_book(exchange_pid, 2) == [
               %{ask_price: 50.0, ask_quantity: 30}
             ]
    end

    test "should return order without asks", %{
      exchange_pid: exchange_pid
    } do
      instruction = %{
        instruction: :new,
        side: :bid,
        price_level_index: 1,
        price: 50.0,
        quantity: 30
      }

      :ok = Exchange.send_instruction(exchange_pid, instruction)

      assert Exchange.order_book(exchange_pid, 2) == [
               %{bid_price: 50.0, bid_quantity: 30}
             ]
    end

    test "should return order book", %{exchange_pid: exchange_pid} do
      :ok =
        Exchange.send_instruction(exchange_pid, %{
          instruction: :new,
          side: :bid,
          price_level_index: 1,
          price: 50.0,
          quantity: 30
        })

      :ok =
        Exchange.send_instruction(exchange_pid, %{
          instruction: :new,
          side: :bid,
          price_level_index: 2,
          price: 40.0,
          quantity: 40
        })

      :ok =
        Exchange.send_instruction(exchange_pid, %{
          instruction: :new,
          side: :ask,
          price_level_index: 1,
          price: 60.0,
          quantity: 10
        })

      :ok =
        Exchange.send_instruction(exchange_pid, %{
          instruction: :new,
          side: :ask,
          price_level_index: 2,
          price: 70.0,
          quantity: 10
        })

      :ok =
        Exchange.send_instruction(exchange_pid, %{
          instruction: :update,
          side: :ask,
          price_level_index: 2,
          price: 70.0,
          quantity: 20
        })

      :ok =
        Exchange.send_instruction(exchange_pid, %{
          instruction: :update,
          side: :bid,
          price_level_index: 1,
          price: 50.0,
          quantity: 40
        })

      order_book = Exchange.order_book(exchange_pid, 2)

      assert order_book == [
               %{ask_price: 60.0, ask_quantity: 10, bid_price: 50.0, bid_quantity: 40},
               %{ask_price: 70.0, ask_quantity: 20, bid_price: 40.0, bid_quantity: 40}
             ]
    end

    test "should return error when updating bid for non-existing level", %{
      exchange_pid: exchange_pid
    } do
      result =
        Exchange.send_instruction(exchange_pid, %{
          instruction: :update,
          side: :bid,
          price_level_index: 1,
          price: 50.0,
          quantity: 30
        })

      assert result == {:error, :price_level_not_found}
    end

    test "should return error when updating ask for non-existing level", %{
      exchange_pid: exchange_pid
    } do
      result =
        Exchange.send_instruction(exchange_pid, %{
          instruction: :update,
          side: :ask,
          price_level_index: 1,
          price: 50.0,
          quantity: 30
        })

      assert result == {:error, :price_level_not_found}
    end
  end
end
