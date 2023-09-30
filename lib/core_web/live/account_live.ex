defmodule CoreWeb.AccountLive do
  @moduledoc false
  use CoreWeb, :live_view

  def list_records(_assigns, _params) do
    Core.Users.list_accounts(fn schema ->
      from(schema, order_by: [desc: :updated_at], preload: [])
    end)
  end

  defp get_record(id) when is_binary(id) do
    Core.Users.get_account(id)
    |> case do
      nil ->
        {:error, :not_found}

      record ->
        record
        |> Core.Repo.preload(organization_memberships: [:organization, :permissions])
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
    |> assign(:page_title, "Accounts")
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
        |> assign(:page_title, "Account / #{record.email_address}")
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
    <table class="min-w-full divide-y divide-gray-300 my-8">
      <thead>
        <tr>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Email Address</th>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Username</th>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Updated</th>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Links</th>
        </tr>
      </thead>
      <tbody class="divide-y divide-gray-200">
        <tr :for={account <- @records}>
          <td class="whitespace-nowrap px-3 py-4 text-sm">
            <i class="fa-solid fa-envelope"></i>
            <a href={"mailto:#{account.email_address}"}>
              <%= account.email_address %>
            </a>
          </td>
          <td class="whitespace-nowrap px-3 py-4 text-sm">
            <%= account.username %>
          </td>
          <td class="whitespace-nowrap px-3 py-4 text-sm">
            <%= account.updated_at %>
          </td>
          <td class="whitespace-nowrap px-3 py-4 text-sm">
            <.link patch={~p"/admin/accounts/#{account.id}"}>
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
    <div style="display: grid; gap: 10px; grid-template-columns: 1fr 1fr 1fr;">
      <div style="padding: 15px; border: 1px solid var(--highlight-500-color);">
        <strong>Email Address</strong>
        <p>
          <a href={"mailto:#{@record.email_address}"}><%= @record.email_address %></a>
        </p>
      </div>
      <div style="padding: 15px; border: 1px solid var(--highlight-500-color);">
        <strong>Organizations</strong>
        <ul>
          <%= for organization_membership <- @record.organization_memberships do %>
            <li>
              <.link patch={~p"/admin/organizations/#{organization_membership.organization.id}"}>
                <%= Pretty.get(organization_membership.organization, :name) %>
              </.link>
              (<%= organization_membership.permissions
              |> Utilities.List.pluck(:name)
              |> Utilities.List.to_sentence() %>)
            </li>
          <% end %>
        </ul>
      </div>

      <div style="padding: 15px; border: 1px solid var(--highlight-500-color);">
        <strong>Onboarding State</strong>
        <p>
          <%= @record.onboarding_state %>
        </p>
      </div>

      <div style="padding: 15px; border: 1px solid var(--highlight-500-color);">
        <strong>Confirmed At</strong>
        <p>
          <time time={@record.confirmed_at}><%= @record.confirmed_at %></time>
        </p>
      </div>

      <div style="padding: 15px; border: 1px solid var(--highlight-500-color);">
        <strong>Inserted At</strong>
        <p>
          <time time={@record.inserted_at}><%= @record.inserted_at %></time>
        </p>
      </div>

      <div style="padding: 15px; border: 1px solid var(--highlight-500-color);">
        <strong>Updated At</strong>
        <p>
          <time time={@record.updated_at}><%= @record.updated_at %></time>
        </p>
      </div>
    </div>
    """
  end
end
