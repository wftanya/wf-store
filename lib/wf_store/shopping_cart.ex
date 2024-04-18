defmodule WfStore.ShoppingCart do
  use GenServer

  def start_link(initial_state \\ %{}) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def add_item(cart_pid, item) do
    GenServer.cast(cart_pid, {:add_item, item})
  end

  def remove_item(cart_pid, item) do
    GenServer.cast(cart_pid, {:remove_item, item})
  end

  def get_cart(cart_pid) do
    GenServer.call(cart_pid, :get_cart)
  end

  # GenServer callbacks
  def init(initial_state) do
    {:ok, initial_state}
  end

  def handle_cast({:add_item, item}, state) do
    new_state = if is_map(state) do
       Map.update(state, item, 1, &(&1 + 1))
    else
      Map.put(%{}, item, 1)
    end

    broadcast_cart_change(new_state)

    {:noreply, new_state}
  end
W
  def handle_cast({:remove_item, item}, state) do
    new_state =
      if Map.has_key?(state, item) && state[item] > 1 do
        Map.update(state, item, 1, &(&1 - 1))
      else
        Map.delete(state, item)
      end

    broadcast_cart_change(new_state)

    {:noreply, new_state}
  end

  def handle_call(:get_cart, _, state) do
    state = if is_map(state) do
      state
    else
      %{}
    end

    {:reply, {:ok, state}, state}
  end

  defp broadcast_cart_change(%{} = cart) do
    Phoenix.PubSub.broadcast(WfStore.PubSub, "user:123", {:cart_change, cart}) # TODO: unique user id otherwise every session is getting these broadcasts every time
    :ok
  end
end