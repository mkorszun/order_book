# OrderBook

Simulates a simplified model of an order book of a financial exchange ([https://en.wikipedia.org/wiki/Order_book_(trading)](https://en.wikipedia.org/wiki/Order_book_(trading))).

## Installation

~~~bash
$ mix compile
~~~

## Testing

~~~bash
$ mix text
~~~

## Design decisions

### Adding new bid/ask

* appends it at the begining of the bids/asks for the given pricing level
* it is possible to add new bid/task with the same price but different quantity
  * it was not clear what is the expected behaviour in such a case

~~~iex
iex(1)> OrderBook.new() |> OrderBook.add_bid(1, 50, 30) |> OrderBook.add_bid(1, 50, 40)
%OrderBook{ask: %{}, bid: %{1 => [{50, 40}, {50, 30}]}}
iex(2)> OrderBook.new() |> OrderBook.add_ask(1, 50, 30) |> OrderBook.add_ask(1, 50, 40)
%OrderBook{ask: %{1 => [{50, 40}, {50, 30}]}, bid: %{}}
~~~

### Deleting bid/ask

* deletes all existing bids/asks at the given pricing level and with the given price

~~~iex
iex(4)> OrderBook.new() |> OrderBook.add_bid(1, 50, 30) |> OrderBook.add_bid(1, 50, 40) |> OrderBook.delete_bid(1, 50)
%OrderBook{ask: %{}, bid: %{1 => []}}
iex(5)> OrderBook.new() |> OrderBook.add_ask(1, 50, 30) |> OrderBook.add_ask(1, 50, 40) |> OrderBook.delete_ask(1, 50)
%OrderBook{ask: %{1 => []}, bid: %{}}
~~~

### Updating bid/ask

* updates all existing bids/asks at the given pricing level and with the given price
  * probably it does not make sense, although the requirement was not clear

~~~iex
iex(6)>  OrderBook.new() |> OrderBook.add_bid(1, 50, 30) |> OrderBook.add_bid(1, 50, 40) |> OrderBook.update_bid(1, 50, 60)
%OrderBook{ask: %{}, bid: %{1 => [{50, 60}, {50, 60}]}}
~~~

## Running

~~~bash
$ iex -S mix
iex(1)> {:ok, exchange_pid} = Exchange.start_link()
iex(2)> :ok =
...(2)>         Exchange.send_instruction(exchange_pid, %{
...(2)>           instruction: :new,
...(2)>           side: :bid,
...(2)>           price_level_index: 1,
...(2)>           price: 50.0,
...(2)>           quantity: 30
...(2)>         }) 
~~~