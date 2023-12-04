defmodule CoreWeb.SlidesheetComponent do
  use(CoreWeb, :live_component)

  @impl true
  def mount(socket) do
    socket
    |> assign(:hidden, true)
    |> (&{:ok, &1}).()
  end

  @impl true
  def handle_event("close", _params, socket) do
    socket
    |> assign(:hidden, true)
    |> (&{:noreply, &1}).()
  end

  @spec open(String.t()) :: 1
  def open(id) do
    send_update(__MODULE__, id: id, hidden: false)
  end

  # @spec slideover(map()) :: Phoenix.LiveView.Rendered.t()
  # attr :label, :string, doc: "A description of the content"
  # attr :rest, :global, include: ~w(disabled form name value class)
  # slot :inner_block, required: true, doc: "The content that is hidden"
  @impl true
  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class={["relative z-10", @hidden && "hidden"]} aria-labelledby={@label} role="dialog" aria-modal="true">
      <!-- Background backdrop, show/hide based on slide-over state. -->
      <div class="fixed inset-0 opacity-40 bg-black"></div>

      <div class="fixed inset-0 overflow-hidden">
        <div class="absolute inset-0 overflow-hidden">
          <div class="pointer-events-none fixed inset-y-0 right-0 flex max-w-full pl-10 transform transition ease-in-out duration-500">
            <!--
              Slide-over panel, show/hide based on slide-over state.

              Entering: "transform transition ease-in-out duration-500"
                From: "translate-x-full"
                To: "translate-x-0"
              Leaving: "transform transition ease-in-out duration-500"
                From: "translate-x-0"
                To: "translate-x-full"
            -->
            <div class="pointer-events-auto w-screen max-w-xl">
              <div class="flex h-full flex-col overflow-y-scroll bg-white py-6 shadow-xl">
                <div class="px-4">
                  <div class="flex items-start justify-between">
                    <h2 class="text-base font-semibold leading-6 text-gray-900"><%= @label %></h2>
                    <div class="ml-3 flex h-7 items-center">
                      <button phx-click="close" phx-target={@myself} type="button" class="relative rounded-md bg-white text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2">
                        <span class="absolute -inset-2.5"></span>
                        <span class="sr-only">Close panel</span>
                        <.icon name="xmark" />
                      </button>
                    </div>
                  </div>
                </div>
                <div class="relative mt-4 flex-1 px-4">
                  <%= render_slot(@inner_block) %>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
