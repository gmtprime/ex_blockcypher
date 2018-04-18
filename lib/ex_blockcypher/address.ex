defmodule ExBlockCypher.Address do
  @moduledoc """
  Define behavior for Address API implementations
  """
  @callback address_balance(String.t(), String.t(), Keyword.t()) :: {:ok, term()}
  @callback address(String.t(), String.t(), Keyword.t()) :: {:ok, term()}
  @callback address_full(String.t(), String.t(), Keyword.t()) :: {:ok, term()}
end

defmodule ExBlockCypher.Address.HTTP do
  @moduledoc """
  Wrapper for BlockCypher's Address API
  using HTTPoison.
  """
  use ExBlockCypher.API

  @behaviour ExBlockCypher.Address

  #  @doc false
  def build_url(endpoint, currency, network, opts) do
    address = Keyword.get(opts, :address)
    IO.puts("Calling build url #{endpoint} #{address}")

    "/#{currency}/#{network}"
    |> do_build_url(endpoint, address)

    # super(endpoint, currency, network, opts)
    # |> do_build_url(endpoint, address)
  end

  defp do_build_url(url, :address_balance, addr), do: url <> "/addrs/#{addr}/balance"
  defp do_build_url(url, :address, addr), do: url <> "/addrs/#{addr}"
  defp do_build_url(url, :address_full, addr), do: url <> "/addrs/#{addr}/full"

  @doc """
  Request Address Balance Endpoint
  """
  def address_balance(currency, address, opts \\ []),
    do: do_get(:address_balance, [address: address], [currency: currency] ++ opts)

  @doc """
  Request Address Endpoint
  """
  def address(currency, address, opts \\ []),
    do: do_get(:address, [address: address], [currency: currency] ++ opts)

  @doc """
  Request Address Full Endpoint
  """
  def address_full(currency, address, opts \\ []),
    do: do_get(:address_full, [address: address], [currency: currency] ++ opts)
end
