defmodule CoreWeb.CampaignLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(
        _params,
        _session,
        %{assigns: %{current_account: %Core.Users.Account{username: username}}}
      )
      when username != "krainboltgreene",
      do: raise(CoreWeb.Exceptions.NotFoundException)

  def mount(
        _params,
        _session,
        %{
          assigns: %{live_action: :list}
        } = socket
      ) do
    campaigns =
      Core.Content.list_campaigns()
      |> Core.Repo.preload(
        opening_scene: [dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc]],
        saves: [last_scene: [dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc]]],
        scenes: [dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc]]
      )

    socket
    |> assign(:campaigns, campaigns)
    |> assign(:page_title, "List of Campaigns")
    |> (&{:ok, &1}).()
  end

  def mount(%{"id" => campaign_id}, _session, %{assigns: %{live_action: :edit}} = socket) do
    campaign =
      Core.Content.get_campaign(campaign_id)
      |> Core.Repo.preload([
        opening_scene: [dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc]],
        saves: [last_scene: [dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc]]],
        scenes: [dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc]]
      ])

    socket
    |> assign(:campaign, campaign)
    |> assign(:page_title, campaign.name)
    |> assign(:page_subtitle, "Campaign")
    |> (&{:ok, &1}).()
  end

  def mount(%{"id" => campaign_id}, _session, %{assigns: %{live_action: :show}} = socket) do
    campaign =
      Core.Content.get_campaign(campaign_id)
      |> Core.Repo.preload([
        opening_scene: [dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc]],
        saves: [last_scene: [dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc]]],
        scenes: [dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc]]
      ])

    socket
    |> assign(:campaign, campaign)
    |> assign(:page_title, campaign.name)
    |> assign(:page_subtitle, "Campaign")
    |> (&{:ok, &1}).()
  end

  @impl true
  @spec handle_params(map(), String.t(), map()) :: {:noreply, map()}
  def handle_params(_params, _url, %{transport_pid: nil} = socket),
    do:
      socket
      |> assign(:page_title, "Loading...")
      |> assign(:page_loading, true)
      |> (&{:noreply, &1}).()

  @impl true
  def handle_params(_params, _url, %{assigns: %{live_action: :edit, campaign: campaign}} = socket) do
    socket
    |> assign(
      :form,
      campaign
      |> Core.Content.change_campaign(from_form(%{}))
      |> to_form()
    )
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("edit", _params, socket) do
    socket
    |> assign(:editing, true)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("validate", %{"campaign" => campaign_params}, %{assigns: %{campaign: campaign}} = socket) do
    socket
    |> assign(
      :campaign_form,
      campaign
      |> Core.Content.change_campaign(from_form(campaign_params))
      |> Map.put(:action, :validate)
      |> then(fn changeset -> to_form(changeset, check_errors: !changeset.valid?) end)
    )
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("save", %{"campaign" => campaign_params}, %{assigns: %{campaign: campaign}} = socket) do
    campaign
    |> Core.Content.update_campaign(from_form(campaign_params))
    |> case do
      {:ok, record} ->
        socket
        |> assign(:campaign, record)
        |> put_flash(:info, "Saved!")
        |> push_patch(to: ~p"/campaigns/#{campaign.id}")
      {:error, changeset} ->
        socket
        |> put_flash(:error, "Woops, something was wrong!")
        |> assign(
          :form,
          to_form(changeset, check_errors: !changeset.valid?)
        )
    end
    |> (&{:noreply, &1}).()
  end

  # @impl true
  # def handle_event(
  #       "build-graph",
  #       _params,
  #       %{assigns: %{campaign: campaign}} = socket
  #     ) do
  #   socket
  #   |> push_event("draw", %{
  #     elements:
  #       [
  #         campaign.scenes
  #         |> Enum.map(fn scene ->
  #           %{
  #             data: %{
  #               group: "nodes",
  #               id: scene.id,
  #               name: scene.name,
  #               type: "scene"
  #             }
  #           }
  #         end),
  #         campaign.scenes
  #         |> Enum.flat_map(fn scene ->
  #           scene.dialogues
  #           |> Enum.flat_map(fn dialogue ->
  #             [
  #               %{
  #                 data: %{
  #                   group: "nodes",
  #                   id: dialogue.id,
  #                   name: dialogue.body,
  #                   type: "dialogue"
  #                 }
  #               },
  #               if dialogue.for_scene_id do
  #                 %{
  #                   data: %{
  #                     group: "edges",
  #                     id: "#{dialogue.id}-#{dialogue.for_scene_id}",
  #                     source: dialogue.for_scene_id,
  #                     target: dialogue.id
  #                   }
  #                 }
  #               end,
  #               if dialogue.next_scene_id do
  #                 %{
  #                   data: %{
  #                     group: "edges",
  #                     id: "#{dialogue.id}-#{dialogue.next_scene_id}",
  #                     source: dialogue.id,
  #                     target: dialogue.next_scene_id
  #                   }
  #                 }
  #               end,
  #               if dialogue.failure_scene_id do
  #                 %{
  #                   data: %{
  #                     group: "edges",
  #                     id: "#{dialogue.id}-#{dialogue.failure_scene_id}",
  #                     source: dialogue.id,
  #                     target: dialogue.failure_scene_id
  #                   }
  #                 }
  #               end
  #             ]
  #             |> Enum.reject(&is_nil/1)
  #           end)
  #         end)
  #       ]
  #       |> Enum.concat()
  #       |> Enum.map(
  #         &Map.merge(&1, %{
  #           grabble: false,
  #           selectable: false
  #         })
  #       )
  #   })
  #   |> (&{:noreply, &1}).()
  # end

  @impl true
  @spec render(%{:live_action => :list | :show, optional(any()) => any()}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{page_loading: true} = assigns) do
    ~H"""
    Loading...
    """
  end

  def render(%{live_action: :list} = assigns) do
    ~H"""
    <ul>
      <li :for={campaign <- @campaigns}><.link navigate={~p"/campaigns/#{campaign.id}"}><%= campaign.name %></.link></li>
    </ul>
    """
  end

  def render(%{live_action: :edit} = assigns) do
    ~H"""
    <.simple_form for={@form} phx-change="validate" phx-submit="save">
      <.input field={@form[:name]} label="Name" type="text" />
      <:actions>
        <.button phx-disable-with="Saving..." type="submit" usable_icon="check">Save</.button>
      </:actions>
    </.simple_form>
    """
  end

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <%!-- <div id="campaign-chart" class="w-full h-80" phx-hook="CampaignGraph"></div> --%>
    <.link navigate={~p"/scenes/new?campaign_id=#{@campaign.id}"}>New Scene</.link>
    <.link navigate={~p"/campaigns/#{@campaign.id}/edit"}>Edit Campaign</.link>
    <.list>
      <:item title="Saves"><%= length(@campaign.saves) %></:item>
      <:item title="Opening scene"><%= Pretty.get(@campaign.opening_scene, :name) %></:item>
      <:item title="Created"><%= @campaign.inserted_at %> (<.timestamp_in_words_ago at={@campaign.inserted_at} />)</:item>
      <:item title="Last updated"><%= @campaign.updated_at %> (<.timestamp_in_words_ago at={@campaign.updated_at} />)</:item>
      <:item title="Scenes">
        <ul>
          <li :for={scene <- @campaign.scenes}>
            <.link navigate={~p"/scenes/#{scene.id}"}><%= Pretty.get(scene, :name) %></.link>
          </li>
        </ul>
      </:item>
      <:item title="Tree">
        <div class="prose">
          <.render_scene scene={@campaign.opening_scene} />
        </div>
      </:item>
    </.list>
    """
  end

  attr :scene, Core.Theater.Scene, required: true

  defp render_scene(assigns) do
    ~H"""
    <.link navigate={~p"/scenes/#{@scene.id}"}><%= Pretty.get(@scene, :name) %></.link>
    <p :for={dialogue <- @scene.dialogues}>
      "<.link navigate={~p"/dialogues/#{dialogue.id}"}><%= dialogue.body %></.link>"
      <%= if !dialogue.next_scene_id do %>
        [leave]
      <% end %>
      <ul>
        <li :if={dialogue.next_scene_id}>
          <.link navigate={~p"/scenes/#{dialogue.next_scene.id}"}><%= dialogue.next_scene.name %></.link>
          <%= if dialogue.failure_scene_id do %>
            [success]
          <% end %>
        </li>
        <li :if={dialogue.failure_scene_id}>
          <.link navigate={~p"/scenes/#{dialogue.failure_scene.id}"}><%= dialogue.failure_scene.name %></.link> [failure]
        </li>
      </ul>
    </p>
    """
  end

  defp from_form(params) when is_map(params) do
    params
    |> Utilities.Map.migrate_lazy("opening_scene", :opening_scene, fn
      "" ->
        nil

      opening_scene_id ->
        Core.Theater.get_scene(opening_scene_id)
    end)
  end
end
