defmodule CoreWeb.JobLive do
  @moduledoc false
  import Ecto.Query
  use CoreWeb, :live_view

  defp default_states(),
    do: [
      "available",
      "scheduled",
      "executing",
      "retryable",
      "completed",
      "discarded"
    ]

  def list_records(_assigns, _params) do
    from(
      job in Oban.Job,
      where:
        job.state in ^(default_states() -- ["completed", "executing", "available", "scheduled"]),
      order_by: [desc: :inserted_at],
      limit: 50
    )
    |> Core.Repo.all()
  end

  defp get_record(id) when is_binary(id) do
    Oban.Job
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
    if connected?(socket), do: Process.send_after(self(), :refresh, 5000)

    socket
    |> assign(:page_title, "Loading...")
    |> (&{:ok, &1}).()
  end

  defp as(socket, :list, params) do
    records = list_records(socket.assigns, params)

    socket
    |> assign(:stats, params["stats"])
    |> assign(:load, params["load"])
    |> assign(:workers, list_of_workers())
    |> assign(:queues, list_of_queues())
    |> assign(:records, records)
    |> assign(:page_title, "Jobs")
  end

  defp as(socket, :show, %{"id" => id}) when is_binary(id) do
    get_record(id)
    |> case do
      {:error, :not_found} ->
        raise CoreWeb.Exceptions.NotFoundException

      record ->
        socket
        |> assign(:record, record)
        |> assign(:page_title, "Job / #{record.id}")
    end
  end

  @impl true
  def handle_info(:refresh, %{assigns: %{live_action: :list}, params: params} = socket) do
    Process.send_after(self(), :refresh, 5000)

    socket
    |> push_patch(to: ~p"/admin/jobs?#{params}", replace: true)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_info(:refresh, %{assigns: %{live_action: :show, record: %{id: id}}} = socket) do
    Process.send_after(self(), :refresh, 5000)

    socket
    |> push_patch(to: ~p"/admin/jobs/#{id}", replace: true)
    |> (&{:noreply, &1}).()
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
  def handle_event("resume_default_queue", _params, socket) do
    Oban.resume_queue(queue: :default)
    |> case do
      :ok ->
        socket
        |> put_flash(:info, "Resuming default queue")
        |> push_patch(to: "/admin/jobs", replace: true)
        |> (&{:noreply, &1}).()
    end
  end

  @impl true
  def handle_event("pause_default_queue", _params, socket) do
    Oban.pause_queue(queue: :default)
    |> case do
      :ok ->
        socket
        |> put_flash(:info, "Pausing default queue")
        |> push_patch(to: "/admin/jobs", replace: true)
        |> (&{:noreply, &1}).()
    end
  end

  @impl true
  def handle_event("retry_all", _params, socket) do
    Oban.retry_all_jobs(Oban.Job)
    |> case do
      {:ok, count} ->
        socket
        |> put_flash(:info, "Retrying #{count} jobs")
        |> push_patch(to: "/admin/jobs", replace: true)
        |> (&{:noreply, &1}).()
    end
  end

  @impl true
  def handle_event("cancel_all", _params, socket) do
    Oban.cancel_all_jobs(Oban.Job)
    |> case do
      {:ok, count} ->
        socket
        |> put_flash(:info, "Killed #{count} jobs")
        |> push_patch(to: "/admin/jobs", replace: true)
        |> (&{:noreply, &1}).()
    end
  end

  @impl true
  def handle_event("retry", %{"id" => id}, socket) do
    Oban.retry_job(String.to_integer(id))

    socket
    |> push_patch(to: "/admin/jobs/#{id}", replace: true)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("cancel", %{"id" => id}, socket) do
    Oban.cancel_job(String.to_integer(id))

    socket
    |> push_patch(to: "/admin/jobs/#{id}", replace: true)
    |> (&{:noreply, &1}).()
  end

  defp list_of_queues() do
    [:default]
    |> Enum.map(fn queue_name -> Oban.check_queue(queue: queue_name) end)
  end

  defp list_of_workers() do
    from(
      job in Oban.Job,
      select: [
        job.worker
      ],
      distinct: [
        job.worker
      ]
    )
    |> Core.Repo.all()
  end

  defp count_by_state(worker) do
    from(
      job in Oban.Job,
      group_by: [:worker, :state],
      where: [worker: ^worker],
      select: [
        job.state,
        count(job)
      ]
    )
    |> Core.Repo.all()
  end

  defp running_per_queue(oban_queue) do
    from(
      job in Oban.Job,
      where: job.id in ^oban_queue.running
    )
    |> Core.Repo.all()
  end

  @impl true
  @spec render(%{live_action: :list | :show}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <.section_title id="stats">
      Worker Stats
      <:tab :for={[worker] <- @workers} patch={~p"/admin/jobs?stats=#{worker}"}><%= worker %></:tab>
    </.section_title>

    <p :if={@stats == nil}>
      Select a worker to see the stats.
    </p>

    <dl :for={[worker] <- @workers} :if={@stats == worker} class="mt-5 grid grid-cols-1 gap-5">
      <div :for={[state, count] <- count_by_state(worker)} class="overflow-hidden rounded-lg bg-white px-4 py-5 shadow">
        <dt class="truncate text-sm font-medium text-gray-500"><%= state %></dt>
        <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900"><%= count %></dd>
      </div>
    </dl>

    <.section_title id="load">
      Queue Load
      <:tab :for={oban_queue <- @queues} patch={~p"/admin/jobs?load=#{oban_queue.queue}"}><%= oban_queue.queue %></:tab>
    </.section_title>

    <p :if={@load == nil}>
      Select a worker to see the queue load.
    </p>

    <dl :for={oban_queue <- @queues} :if={@load == oban_queue.queue} class="mt-5 grid grid-cols-1 gap-5">
      <div :for={job <- running_per_queue(oban_queue)} class="overflow-hidden rounded-lg bg-white px-4 py-5 shadow">
        <dt class="truncate text-sm font-medium text-gray-500"><%= job.state %> (<%= job.attempt %>/<%= job.max_attempts %>) on <%= oban_queue.node %></dt>
        <dd class="mt-1 text-3xl font-semibold tracking-tight text-gray-900">
          <.link patch={~p"/admin/jobs/#{job.id}"}>
            #<%= job.id %>
          </.link>
        </dd>
      </div>
    </dl>

    <.section_title id="actions">Actions</.section_title>
    <section>
      <%= if Oban.check_queue(queue: :default).paused do %>
        <.button type="button" phx-click="resume_default_queue" usable_icon="play">
          Resume Default Queue
        </.button>
      <% else %>
        <.button type="button" phx-click="pause_default_queue" usable_icon="pause">
          Pause Default Queue
        </.button>
      <% end %>
      <.button type="button" phx-click="retry_all" usable_icon="recycle">Retry All</.button>
      <.button type="button" phx-click="cancel_all" usable_icon="times">Cancel All</.button>
    </section>

    <.section_title id="failing">Failing</.section_title>
    <table class="min-w-full divide-y divide-gray-300 my-8">
      <thead>
        <tr>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">ID</th>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Worker</th>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">State</th>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Queue</th>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Attempts</th>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold">Started</th>
          <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold"></th>
        </tr>
      </thead>
      <tbody class="divide-y divide-gray-200">
        <tr :for={job <- @records}>
          <td class="whitespace-nowrap px-3 py-4 text-sm">
            <.link patch={~p"/admin/jobs/#{job.id}"}>
              #<%= job.id %>
            </.link>
          </td>
          <td class="whitespace-nowrap px-3 py-4 text-sm"><%= job.worker %></td>
          <td class="whitespace-nowrap px-3 py-4 text-sm"><%= job.state %></td>
          <td class="whitespace-nowrap px-3 py-4 text-sm"><%= job.queue %></td>
          <td class="whitespace-nowrap px-3 py-4 text-sm"><%= job.attempt %>/<%= job.max_attempts %></td>
          <td class="whitespace-nowrap px-3 py-4 text-sm"><time datetime={job.inserted_at}><%= Timex.from_now(job.inserted_at) %></time></td>
          <td class="whitespace-nowrap px-3 py-4 text-sm">
            <section>
              <.button type="button" phx-click="retry" phx-value-id={job.id} usable_icon="recycle">
                Retry
              </.button>
              <.button type="button" phx-click="cancel" phx-value-id={job.id} usable_icon="times">
                Cancel
              </.button>
            </section>
          </td>
        </tr>
      </tbody>
    </table>
    """
  end

  @impl true
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <div>
      <div class="px-4">
        <h3 class="text-base font-semibold leading-7 text-gray-900">Actions</h3>
        <p class="mt-1 max-w-2xl text-sm leading-6 text-gray-500">
          <.button type="button" phx-click="retry" phx-value-id={@record.id} usable_icon="recycle">
            Retry
          </.button>
          <.button type="button" phx-click="cancel" phx-value-id={@record.id} usable_icon="times">
            Cancel
          </.button>
        </p>
      </div>
      <div class="mt-6 border-t border-gray-100">
        <dl class="divide-y divide-gray-100">
          <div class="px-4 py-6">
            <dt class="text-sm font-medium leading-6 text-gray-900">Arguments</dt>
            <dd class="mt-1 text-sm leading-6 text-gray-700"><%= elixir_as_html(@record.args) %></dd>
          </div>
          <div class="px-4 py-6">
            <dt class="text-sm font-medium leading-6 text-gray-900">Queue</dt>
            <dd class="mt-1 text-sm leading-6 text-gray-700">
              <%= @record.queue %>
            </dd>
          </div>
          <div class="px-4 py-6">
            <dt class="text-sm font-medium leading-6 text-gray-900">State</dt>
            <dd class="mt-1 text-sm leading-6 text-gray-700">
              <%= @record.state %>
            </dd>
          </div>
          <div :if={@record.attempted_by} class="px-4 py-6">
            <dt class="text-sm font-medium leading-6 text-gray-900">Attempted By</dt>
            <dd class="mt-1 text-sm leading-6 text-gray-700">
              <ul :for={node <- @record.attempted_by} role="list" class="divide-y divide-gray-100 rounded-md border border-gray-200">
                <li class="flex items-center justify-between py-4 pl-4 pr-5 text-sm leading-6">
                  <div class="ml-4 flex-shrink-0">
                    <.icon as="computer" />
                    <%= node %>
                  </div>
                </li>
              </ul>
            </dd>
          </div>
          <div :if={@record.errors} class="px-4 py-6">
            <dt id="errors" class="text-sm font-medium leading-6 text-gray-900">Errors</dt>
            <dd class="mt-1 text-sm leading-6 text-gray-700">
              <ul :for={error <- Enum.reverse(@record.errors)} role="list" class="divide-y divide-gray-100 rounded-md border border-gray-200">
                <li class="flex items-center justify-between py-4 pl-4 pr-5 text-sm leading-6">
                  <div class="ml-4 flex-shrink-0 max-w-full">
                    <.icon as="clock" />
                    <time title={error["at"]} datetime={error["at"]}><%= error_at_ago(error) %></time>
                    <%= code_as_html(error["error"]) %>
                  </div>
                </li>
              </ul>
            </dd>
          </div>
          <div class="px-4 py-6">
            <dt class="text-sm font-medium leading-6 text-gray-900">Inserted At</dt>
            <dd class="mt-1 text-sm leading-6 text-gray-700">
              <time title={@record.inserted_at} datetime={@record.inserted_at}>
                <%= Timex.from_now(@record.inserted_at) %>
              </time>
            </dd>
          </div>
          <div :if={@record.completed_at} class="px-4 py-6">
            <dt class="text-sm font-medium leading-6 text-gray-900">Completed At</dt>
            <dd class="mt-1 text-sm leading-6 text-gray-700">
              <time title={@record.completed_at} datetime={@record.completed_at}>
                <%= Timex.from_now(@record.completed_at) %>
              </time>
            </dd>
          </div>
          <div :if={@record.cancelled_at} class="px-4 py-6">
            <dt class="text-sm font-medium leading-6 text-gray-900">Cancelled At</dt>
            <dd class="mt-1 text-sm leading-6 text-gray-700">
              <time title={@record.cancelled_at} datetime={@record.cancelled_at}>
                <%= Timex.from_now(@record.cancelled_at) %>
              </time>
            </dd>
          </div>
          <div :if={@record.discarded_at} class="px-4 py-6">
            <dt class="text-sm font-medium leading-6 text-gray-900">Discarded At</dt>
            <dd class="mt-1 text-sm leading-6 text-gray-700">
              <time title={@record.discarded_at} datetime={@record.discarded_at}>
                <%= Timex.from_now(@record.discarded_at) %>
              </time>
            </dd>
          </div>
          <div :if={@record.attempted_at} class="px-4 py-6">
            <dt class="text-sm font-medium leading-6 text-gray-900">Attempts</dt>
            <dd class="mt-1 text-sm leading-6 text-gray-700">
              <time title={@record.attempted_at} datetime={@record.attempted_at}>
                <%= Timex.from_now(@record.attempted_at) %>
              </time>
            </dd>
          </div>
          <div :if={@record.attempted_at} class="px-4 py-6">
            <dt class="text-sm font-medium leading-6 text-gray-900">Attempts</dt>
            <dd class="mt-1 text-sm leading-6 text-gray-700">
              <%= @record.attempt %> of <%= @record.max_attempts %> (last attempt <time title={@record.attempted_at} datetime={@record.attempted_at}><%= Timex.from_now(@record.attempted_at) %></time>)
            </dd>
          </div>
        </dl>
      </div>
    </div>
    """
  end
end
