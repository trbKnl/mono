defmodule Port.StartPages do
  @behaviour CoreWeb.StartPageProvider

  def pages(),
    do: %{
      projects: %{id: :projects, target: Systems.Project.OverviewPage, domain: "eyra-ui"}
    }

  @impl true
  def values(),
    do: %{
      researcher: pages().projects,
      student: pages().projects,
      coordinator: pages().projects,
      member: pages().projects
    }

  defmacro __using__(_opts) do
    quote do
      import CoreWeb.Gettext

      unquote do
        for {id, %{domain: domain}} <- Port.StartPages.pages() do
          quote do
            dgettext(unquote(domain), unquote("start.page.#{id}"))
          end
        end
      end
    end
  end
end