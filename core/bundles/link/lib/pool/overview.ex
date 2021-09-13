defmodule Link.Pool.Overview do
  @moduledoc """
   The student overview screen.
  """
  use CoreWeb, :live_view
  use CoreWeb.Layouts.Workspace.Component, :studentpool

  import CoreWeb.Gettext

  alias Link.Pool.Form.{Students, Studies}

  alias CoreWeb.Layouts.Workspace.Component, as: Workspace
  alias CoreWeb.UI.Navigation.{ActionBar, TabbarArea, Tabbar, TabbarContent}

  data(tabs, :any)

  @impl true
  def mount(%{"tab" => active_tab}, _session, socket) do
    tabs = create_tabs(active_tab)

    {
      :ok,
      socket
      |> assign(tabs: tabs)
      |> update_menus()
    }
  end

  @impl true
  def mount(_params, session, socket) do
    mount(%{"tab" => "students"}, session, socket)
  end

  defp create_tabs(active_tab) do
    [
      %{
        id: :students,
        title: dgettext("link-studentpool", "tabbar.item.students"),
        component: Students,
        props: nil,
        type: :fullpage,
        active: active_tab === :students
      },
      %{
        id: :studies,
        title: dgettext("link-studentpool", "tabbar.item.studies"),
        component: Studies,
        props: nil,
        type: :fullpage,
        active: active_tab === :studies
      }
    ]
  end

  def render(assigns) do
    ~H"""
      <Workspace
        title={{ dgettext("link-studentpool", "title") }}
        menus={{ @menus }}
      >
        <TabbarArea tabs={{@tabs}}>
          <ActionBar>
            <Tabbar initial_tab={{ :students }} />
          </ActionBar>
          <TabbarContent/>
        </TabbarArea>
      </Workspace>
    """
  end
end