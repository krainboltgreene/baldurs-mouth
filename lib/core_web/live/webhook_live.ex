defmodule CoreWeb.WebhookLive do
  @moduledoc false
  use CoreWeb, :live_view

  def list_records(_assigns, _params) do
    Core.Content.list_webhooks(fn schema ->
      from(schema, order_by: [desc: :updated_at], preload: [])
    end)
  end

  defp get_record(id) when is_binary(id) do
    Core.Content.Webhook
    |> Core.Repo.get(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :refresh, 2500)

    socket
    |> assign(:page_title, "Loading...")
    |> (&{:ok, &1}).()
  end

  defp as(socket, :list, params) do
    socket
    |> assign(:page_title, "Webhooks")
    |> assign(:records, list_records(socket.assigns, params))
  end

  defp as(socket, :show, %{"id" => id}) when is_binary(id) do
    get_record(id)
    |> case do
      {:error, :not_found} ->
        raise CoreWeb.Exceptions.NotFoundException

      record ->
        socket
        |> assign(:record, record)
        |> assign(:page_title, "Webhook / #{record.id}")
    end
  end

  @impl true
  def handle_info(:refresh, %{assigns: %{live_action: :list}} = socket) do
    Process.send_after(self(), :refresh, 2500)
    {:noreply, push_patch(socket, to: ~p"/admin/webhooks")}
  end

  @impl true
  def handle_info(:refresh, %{assigns: %{live_action: :show, record: %{id: id}}} = socket) do
    Process.send_after(self(), :refresh, 2500)
    {:noreply, push_patch(socket, to: ~p"/admin/webhooks/#{id}")}
  end

  @impl true
  def handle_info(:refresh, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket
    |> as(socket.assigns.live_action, params)
    |> (&{:noreply, &1}).()
  end

  @impl true
  @spec render(%{:live_action => :list | :show, optional(any) => any}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <table class="min-w-full divide-y divide-gray-300 my-8">
      <thead>
        <tr>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">ID</th>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Provider</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-gray-200">
        <%= for webhook <- @records do %>
          <tr>
            <td class="whitespace-nowrap px-3 py-4 text-sm">
              <.link patch={~p"/admin/webhooks/#{webhook.id}"}>
                <%= webhook.id %>
              </.link>
            </td>
            <td class="whitespace-nowrap px-3 py-4 text-sm">
              <%= webhook.provider %>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h3 id="headers">Headers</h3>
    <p>
      <%= elixir_as_html(@record.headers) %>
    </p>

    <h3 id="arguments">Arguments</h3>
    <p>
      <%= elixir_as_html(@record.payload) %>
    </p>
    """
  end
end
