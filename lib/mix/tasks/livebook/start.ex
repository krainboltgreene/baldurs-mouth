defmodule Mix.Tasks.Livebook.Start do
  @moduledoc false
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    System.cmd("which", ["livebook"])
    |> case do
      {_, 0} -> "livebook"
      _ -> "~/.asdf/installs/elixir/1.14.3/.mix/escripts/livebook"
    end
    |> System.cmd(
      [
        "server",
        "--home",
        "docs/livebook/",
        "open"
      ],
      env: [
        {"LIVEBOOK_DATA_PATH", "tmp/livebook-data"},
        {"LIVEBOOK_DEFAULT_RUNTIME", "attached:core@eberkeley:core"},
        {"LIVEBOOK_SHUTDOWN_ENABLED", "true"}
      ],
      into: IO.stream()
    )
  end
end
