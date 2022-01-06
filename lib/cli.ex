defmodule Identicon.CLI do
  def main(args \\ []) do
    args
    |> parse_args()
    |> response()
    |> IO.puts()
  end

  defp parse_args(args) do
    {opts, name, _} =
      args
      |> OptionParser.parse(switches: [file: :string])

    {opts, name}
  end

  defp response({opts, name}) do
    if opts[:file], do: Identicon.main(name, opts[:file]), else: Identicon.main(name, name)
  end
end
