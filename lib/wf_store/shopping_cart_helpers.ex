defmodule WfStore.ShoppingCartHelpers do
  alias WfStore.ShoppingCart
  
  def get_pid do
    case ShoppingCart.start_link() do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def get_cart_count(%{} = cart) do
    cart
    |> Map.values()
    |> Enum.sum()
  end
end