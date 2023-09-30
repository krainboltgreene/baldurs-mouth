defmodule CoreWeb.OrganizationLive do
  @moduledoc false
  use CoreWeb, :live_view

  def list_records(_assigns, _params) do
    Core.Users.list_organizations()
  end

  defp get_record(id) when is_binary(id) do
    Core.Users.get_organization(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> Core.Repo.preload([:accounts])
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "Loading...")
    |> (&{:ok, &1}).()
  end

  defp as(socket, :list, params) do
    socket
    |> assign(:page_title, "Organizations")
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
        |> assign(:page_title, "Organization / #{Pretty.get(record, :name)}")
    end
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
    <table class="min-w-full divide-y divide-gray-300 my-4">
      <thead>
        <tr>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Name</th>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Updated</th>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Links</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-gray-200">
        <tr :for={organization <- @records}>
          <td class="whitespace-nowrap px-3 py-4 text-sm text-black-500">
            <%= Pretty.get(organization, :name) %>
          </td>
          <td class="whitespace-nowrap px-3 py-4 text-sm">
            <.timestamp_in_words_ago at={organization.updated_at} />
          </td>
          <td class="whitespace-nowrap px-3 py-4 text-sm">
            <.link patch={~p"/admin/organizations/#{organization.id}"}>
              Show
            </.link>
          </td>
        </tr>
      </tbody>
    </table>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <h3 id="accounts">Accounts</h3>
    <ul>
      <%= for account <- @record.accounts do %>
        <li>
          <.link patch={~p"/admin/accounts/#{account.id}"}><%= account.username %></.link>
        </li>
      <% end %>
    </ul>
    """
  end
end
