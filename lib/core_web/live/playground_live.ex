defmodule CoreWeb.PlaygroundLive do
  @moduledoc false
  use CoreWeb, [:live_view, :empty]

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Loading...")
    |> (&{:ok, &1}).()
  end

  defp as(socket, :list, _params) do
    socket
    |> assign(:page_title, "Playground")
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <.section_title id="buttons">Buttons</.section_title>
    <section>
      <.button state="busy" usable_icon="save">Busy</.button>
      <.button state="rejection" usable_icon="triangle-exclamation">Rejection</.button>
      <.button state="failure" usable_icon="xmark">Failure</.button>
      <.button state="successful" usable_icon="check">Success</.button>
      <.button state="usable" usable_icon="save">Using</.button>
    </section>
    <.section_title id="flash">Flash</.section_title>
    <section>
      <.flash kind={:info} flash={%{"info" => "a message"}} />
      <.flash kind={:error} flash={%{"error" => "a message"}} />
      <.flash kind={:error} flash={%{"error" => ["a message 1", "a message 2"]}} />
    </section>
    """
  end
end
