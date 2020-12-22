defmodule GitSearchWeb.PageLive do
  use GitSearchWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query)}
  end

  defp search(_query) do
    [
      %{
        name: "one",
        link: "https://docs.github.com/en/free-pro-team@latest/rest/reference/search"
      },
      %{
        name: "two",
        link: "https://docs.github.com/en/free-pro-team@latest/rest/reference/search"
      },
      %{
        name: "three",
        link: "https://docs.github.com/en/free-pro-team@latest/rest/reference/search"
      }
    ]
  end
end
