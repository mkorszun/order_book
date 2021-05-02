defmodule Exchange do
  use GenServer

  # API

  @spec start_link :: :ignore | {:error, any} | {:ok, pid}
  def start_link(), do: GenServer.start_link(__MODULE__, [])

  @spec send_instruction(atom | pid | {atom, any} | {:via, atom, any}, any) :: :ok | {:error, any}
  def send_instruction(pid, instruction) do
    GenServer.call(pid, {:process_instruction, instruction})
  end

  @spec order_book(atom | pid | {atom, any} | {:via, atom, any}, any) :: List.t() | {:error, any}
  def order_book(pid, book_depth) do
    GenServer.call(pid, {:get_order_book, book_depth})
  end

  # CALLBACKS

  @impl GenServer
  def init(_), do: {:ok, OrderBook.new()}

  @impl GenServer
  def handle_call({:process_instruction, instruction}, _, order_book) do
    case process_instruction(order_book, instruction) do
      {:error, _} = error ->
        {:reply, error, order_book}

      updated_book ->
        {:reply, :ok, updated_book}
    end
  end

  @impl GenServer
  def handle_call({:get_order_book, book_depth}, _, order_book) do
    {:reply, OrderBook.order(order_book, book_depth), order_book}
  end

  # HELPERS

  defp process_instruction(order_book, %{instruction: :new, side: :bid} = instruction) do
    order_book
    |> OrderBook.add_bid(
      instruction[:price_level_index],
      instruction[:price],
      instruction[:quantity]
    )
  end

  defp process_instruction(order_book, %{instruction: :new, side: :ask} = instruction) do
    order_book
    |> OrderBook.add_ask(
      instruction[:price_level_index],
      instruction[:price],
      instruction[:quantity]
    )
  end

  defp process_instruction(order_book, %{instruction: :update, side: :ask} = instruction) do
    order_book
    |> OrderBook.update_ask(
      instruction[:price_level_index],
      instruction[:price],
      instruction[:quantity]
    )
  end

  defp process_instruction(order_book, %{instruction: :update, side: :bid} = instruction) do
    order_book
    |> OrderBook.update_bid(
      instruction[:price_level_index],
      instruction[:price],
      instruction[:quantity]
    )
  end

  defp process_instruction(order_book, %{instruction: :delete, side: :ask} = instruction) do
    order_book
    |> OrderBook.delete_ask(
      instruction[:price_level_index],
      instruction[:price]
    )
  end

  defp process_instruction(order_book, %{instruction: :delete, side: :bid} = instruction) do
    order_book
    |> OrderBook.delete_bid(
      instruction[:price_level_index],
      instruction[:price]
    )
  end
end
