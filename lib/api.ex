defmodule ExBlockCypher.API do
  @moduledoc """
  Define basic functions for each module of the API.

  This module uses HTTPoison.Base to process requests and responses.
  Responses are decoded using Poison.
  """

  defmacro __using__(_opts) do
    quote do
      use HTTPoison.Base

      alias ExBlockCypher.Parser

      @default_currency :btc
      @default_network :main
      @req_options [:headers, :currency, :network, :httpoison_opts]

      @spec get_config(atom()) :: term()
      def get_config(key) do
        Application.get_env(:ex_blockcypher, key)
      end

      @spec build_url(atom(), String.t(), String.t(), Keyword.t()) :: String.t()
      def build_url(endpoint, currency, network, opts \\ [])

      def build_url(_, currency, network, _opts) do
        "/#{currency}/#{network}"
      end

      @doc """
      Override HTTPoison.Base.process_url function to concat
      BlockCypher's API URL with the endpoint.
      """
      def process_url(url), do: get_config(:api_url) <> url

      @doc """
      GET requests to the API
      """
      @spec do_get(atom(), Keyword.t(), Keyword.t()) :: term()
      def do_get(endpoint, params, opts) do
        do_request(endpoint, :get, "", params, opts)
      end

      @spec do_post(atom(), term(), Keyword.t(), Keyword.t()) :: term()
      def do_post(endpoint, body, params, opts) do
        do_request(endpoint, :post, body, params, opts)
      end

      @doc """
      Decode JSON Response's body using Poison
      """
      def process_response_body(binary) do
        case Poison.decode(binary) do
          {:error, _} -> binary
          {:ok, decoded} -> decoded
        end
      end

      defp do_request(endpoint, method, body, params, opts) do
        # API flags - query parameters
        api_flags =
          opts
          |> Enum.filter(fn {x, _} -> x not in @req_options end)

        headers = Keyword.get(opts, :headers, [])
        currency = Keyword.get(opts, :currency, @default_currency)
        network = Keyword.get(opts, :network, @default_network)
        httpoison_opts = Keyword.get(opts, :httpoison_opts, [])
        # API's flags should be passed as query params to HTTPoison
        url = build_url(endpoint, currency, network, params)
        options = [params: api_flags] ++ httpoison_opts
        # Now properly request the API
        request(method, url, body, headers, options)
        |> Parser.parse()
      end

      defoverridable build_url: 4
    end
  end
end
