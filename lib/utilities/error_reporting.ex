defmodule Utilities.ErrorReporting do
  @moduledoc """
  This module handles any special error reporting behavior.
  """

  @doc """
  When an Oban job fails we want to send the failure directly to Sentry
  """
  def handle_event([:oban, :job, :exception], measure, meta, _) do
    extra =
      meta.job
      |> Map.take([:id, :args, :meta, :queue, :worker])
      |> Map.merge(measure)

    Sentry.capture_exception(meta.reason, stacktrace: meta.stacktrace, extra: extra)
  end
end
