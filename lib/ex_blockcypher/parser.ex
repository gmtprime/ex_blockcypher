defmodule ExBlockCypher.Parser do
  @moduledoc """
  Define functions to parse Response from the API
  """

  @type http_status :: integer

  @doc """
  Parse the API's HTTPoison.Response
  """
  @spec parse(tuple()) :: :ok | {:ok, struct} | {:error, term(), http_status} | {:error, map}
  def parse(response) do
    case response do
      {:ok, %HTTPoison.Response{body: body, status_code: status}} when status in  [200, 201] ->
        {:ok, body}
      {:ok, %HTTPoison.Response{body: _, status_code: 204}} -> :ok

      {:ok, %HTTPoison.Response{ body: body, status_code: status}} when status >= 400 ->
        {:error, body, status}

        #      {:ok, %HTTPoison.Response{body: body, status_code: status) ->

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %{reason: reason}}

      _ -> response
    end
  end
end
