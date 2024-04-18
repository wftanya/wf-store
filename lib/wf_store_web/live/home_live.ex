defmodule WfStoreWeb.HomeLive do
  use WfStoreWeb, :live_view

  alias Phoenix.LiveView.Socket
  alias WfStore.ShoppingCart
  alias WfStore.ShoppingCartHelpers

  @default_assigns %{
    added: nil,
    cart: nil,
    cart_count: 0,
    cart_pid: nil,
    modal: nil,
    products: [
      %{
        id: 1,
        name: "Today Flipping Sucks Tee",
        description: "Proceeds of this tee go towards sewerslide prevention",
        image_url: "images/skull-tee.png",
        price: "$35.99"
      },
      %{
        id: 2,
        name: "Drunk Phone Lanyard",
        description: "With Press Pass. Phone case not included",
        image_url: "images/drunk-lanyard.jpg",
        price: "$5.99"
      },
      %{
        id: 3,
        name: "Hannah Mountain Backpack",
        description: "",
        image_url: "images/hannah-montan.png",
        price: "$15.99"
      },
      %{
        id: 4,
        name: "Velvet Q-Tip",
        description: "Pack of 3",
        image_url: "images/velvetqtip.png",
        price: "$4.99"
      },
      %{
        id: 5,
        name: "The Dragon with the Girl Tattoo",
        description: "By Adam Roberts (Paperback)",
        image_url: "images/dragon-girl-tattoo.png",
        price: "$15.99"
      },
      %{
        id: 6,
        name: "?????????????",
        description: "???????????",
        image_url: "images/insporational-squidward-godizlla.jpg",
        price: "$99999.99"
      },
      %{
        id: 7,
        name: "Morris",
        description: "Trusty walking stick",
        image_url: "images/morris.png",
        price: "$35.99"
      },
      %{
        id: 8,
        name: "(Human) Shrek Body (Love) Pillow",
        description: "Full sized",
        image_url: "images/shrek-body.png",
        price: "$79.99"
      },
      %{
        id: 9,
        name: "Lucy the Roach Clip",
        description: "",
        image_url: "images/lucy.png",
        price: "$7.99"
      },
      %{
        id: 10,
        name: "Best Friend Backpack (the BFB)™",
        description: "You'll never need another backpack again",
        image_url: "images/bfb.jpg",
        price: "$54.99"
      },
      %{
        id: 11,
        name: "John Xina Frame",
        description: "",
        image_url: "images/john-xina.png",
        price: "$19.99"
      },
      %{
        id: 12,
        name: "Gravestone with Speaker",
        description: "Proximity sensor speaker that plays spooky sounds",
        image_url: "images/gravestone.png",
        price: "$99.99"
      },
      %{
        id: 13,
        name: "Misfortune Cookie",
        description: "",
        image_url: "images/misfortune-cookie.jpg",
        price: "$1.99"
      },
      %{
        id: 14,
        name: "Taxidermy Thong",
        description: "",
        image_url: "images/taxidermy.jpg",
        price: "$31.99"
      },
      %{
        id: 15,
        name: "Spunch Bob Tee",
        description: "",
        image_url: "images/spunch-bob.jpg",
        price: "$12.99"
      },
      %{
        id: 16,
        name: "Bathroom Mat",
        description: "",
        image_url: "images/cringe-bathroom.png",
        price: "$25.99"
      },
      %{
        id: 17,
        name: "Sobe Beverage",
        description: "Strawberry Flavour (discontinued)",
        image_url: "images/sobe.jpg",
        price: "$5.99"
      },
      %{
        id: 18,
        name: "Sonic Backpack",
        description: "",
        image_url: "images/sonic-obama.png",
        price: "$15.99"
      },
      %{
        id: 19,
        name: "Drug Baggies (Pack of 10)",
        description: "Spongebob Theme",
        image_url: "images/spongebobbaggie.jpg",
        price: "$1.99"
      },
      %{
        id: 20,
        name: "Drug Baggies (Pack of 100)",
        description: "Unicorn Theme",
        image_url: "images/baggies.png",
        price: "$7.99"
      },
      %{
        id: 21,
        name: "Shrek Tee",
        description: "",
        image_url: "images/awsexy.png",
        price: "$20.99"
      },
      %{
        id: 22,
        name: "Shrek x Christiano Ronaldo Poster",
        description: "32\" x 16\"",
        image_url: "images/shrek-christiano-poster.png",
        price: "$15.99"
      }
    ]
  }

  def render(assigns) do
    Phoenix.View.render(WfStoreWeb.HomeView, "home.html", assigns)
  end

  def mount(_, _, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(WfStore.PubSub, "user:123") # TODO: unique user id otherwise every session is getting these broadcasts every time
    end

    cart_pid = ShoppingCartHelpers.get_pid()
    {:ok, cart} = ShoppingCart.get_cart(cart_pid)
    cart_count = ShoppingCartHelpers.get_cart_count(cart)
 
    socket = socket |> assign(@default_assigns)  |>  assign(:cart_pid, cart_pid) |>  assign(:cart, cart) |> assign(:cart_count, cart_count)

    {:ok, socket}
  end

  def handle_event("add_to_cart", %{"product" => product_id}, %Socket{assigns: %{cart_pid: pid}} = socket) do
    ShoppingCart.add_item(pid, product_id)

    Process.send_after(self(), :clear_added, 3000)

    {:noreply,  assign(socket, :added, product_id) }
  end

  def handle_event("open_cart", _, %Socket{} = socket) do
    {:noreply, assign(socket, :modal, :troll_cart) }
  end

  # Message handler for the shopping cart pubsub updates
  def handle_info({:cart_change, %{} = cart}, %Socket{} = socket) do
    cart_count = ShoppingCartHelpers.get_cart_count(cart)
    {:noreply, assign(socket, :cart_count, cart_count)}
  end

  def handle_info(:clear_added, %Socket{} = socket) do
    {:noreply, assign(socket, :added, nil)}
  end
end
