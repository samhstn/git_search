defmodule GitSearchWeb.PageLive do
  use GitSearchWeb, :live_view

  @github_repo_url "https://api.github.com/search/repositories"
  @repo_limit 10

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: [])}
  end

  @impl true
  def handle_event("search", %{"q" => ""}, socket) do
    {:noreply, assign(socket, query: "", results: [])}
  end

  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      {:ok, results} ->
        {:noreply, assign(socket, query: query, results: results)}

      {:error, error} ->
        {
          :noreply,
          socket
          |> put_flash(:error, "An unexpected error occurred while searching: #{error}")
          |> assign(query: query, results: [])
        }
    end
  end

  @spec search(String.t()) :: {:ok, [String.t()]} | {:error, String.t()}
  defp search(query) do
    with {:ok, response} <- HTTPoison.get("#{@github_repo_url}?q=#{query}"),
         %HTTPoison.Response{status_code: 200} <- response,
         {:ok, parsed_body} <- Jason.decode(response.body) do
      results =
        parsed_body
        |> Map.get("items")
        |> Enum.map(fn %{"full_name" => full_name} -> full_name end)
        |> Enum.take(@repo_limit)

      {:ok, results}
    else
      {:error, error} when error.__struct__ == HTTPoison.Error ->
        {:error, HTTPoison.Error.message(error)}

      {:error, error} when error.__struct__ == Jason.DecodeError ->
        {:error, Jason.DecodeError.message(error)}

      %HTTPoison.Response{status_code: 403} ->
        {:error, "Our search rate limit has been exceeded, please try again later."}
    end
  end
end
