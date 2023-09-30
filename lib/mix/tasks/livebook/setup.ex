defmodule Mix.Tasks.Livebook.Setup do
  @moduledoc false
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    Mix.Tasks.Escript.Install.run(["hex", "livebook"])
    System.cmd("mkdir", ["-p", "docs/livebook"])
  end
end
