defmodule PageScraperWeb.PageHelper do
  @moduledoc """
  Helper methods to be used in templates.
  """

  def polling_frequency_options do
    seconds = Enum.map((1..59), fn i -> ["seconds(#{i})": i * 1000] end)
    minutes = Enum.map((1..60), fn i -> ["minutes(#{i})": i * 60_000] end)
    (seconds ++ minutes) |> List.flatten
  end

  def humanize_polling_frequency(seconds) do
    polling_frequency_options()
    |> Enum.find_value(fn option ->
      {key, value} = option

      if value == seconds, do: key
    end)
  end
end
