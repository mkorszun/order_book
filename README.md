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