defmodule Mix.Tasks.Phx.Gen.LiveViewTest do
  @shortdoc "Generates a basic test for a live view module"
  @moduledoc """
      $ mix phx.gen.live_view_test
  """
  use Mix.Task

  def run(args) do
    if Mix.Project.umbrella?() do
      Mix.raise(
        "mix phx.gen.live_view_test must be invoked from within your *_web application root directory"
      )
    end

    {context, schema} = Mix.Tasks.Phx.Gen.Context.build(args)

    binding = [context: context, schema: schema]
    paths = Mix.Phoenix.generator_paths()

    prompt_for_conflicts(context)

    context
    |> copy_new_files(binding, paths)
  end

  defp copy_new_files(%Mix.Phoenix.Context{} = context, binding, paths) do
    files = files_to_be_generated(context)
    Mix.Phoenix.copy_from(paths, "priv/templates/phx.gen.live_view_test", binding, files)

    context
  end

  defp prompt_for_conflicts(context) do
    context
    |> files_to_be_generated()
    |> Mix.Phoenix.prompt_for_conflicts()
  end

  defp files_to_be_generated(%Mix.Phoenix.Context{schema: schema, context_app: context_app}) do
    test_prefix = Mix.Phoenix.web_test_path(context_app)
    web_path = to_string(schema.web_path)

    [
      {:eex, "example.ex",
       Path.join([test_prefix, web_path, "live", "#{schema.singular}_live_test.exs"])}
    ]
  end
end
