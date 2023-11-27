defmodule Systems.Project.OverviewPage do
  use CoreWeb, :live_view
  use CoreWeb.Layouts.Workspace.Component, :projects
  use CoreWeb.UI.PlainDialog
  use Systems.Observatory.Public

  import CoreWeb.Layouts.Workspace.Component
  alias CoreWeb.UI.SelectorDialog

  alias Frameworks.Pixel.Button
  alias Frameworks.Pixel.Grid
  alias Frameworks.Pixel.Text
  alias Frameworks.Pixel.Button
  alias Frameworks.Pixel.ShareView

  alias Systems.{
    Project
  }

  def mount(_params, _session, %{assigns: %{current_user: user}} = socket) do
    {
      :ok,
      socket
      |> assign(
        model: user,
        dialog: nil,
        popup: nil,
        selector_dialog: nil
      )
      |> observe_view_model()
      |> update_menus()
    }
  end

  def handle_view_model_updated(socket) do
    socket |> update_menus()
  end

  def handle_auto_save_done(socket) do
    socket |> update_menus()
  end

  @impl true
  def handle_event(
        "card_clicked",
        %{"item" => card_id},
        %{assigns: %{vm: %{cards: cards}}} = socket
      ) do
    card_id = String.to_integer(card_id)
    %{path: path} = Enum.find(cards, &(&1.id == card_id))
    {:noreply, push_redirect(socket, to: path)}
  end

  @impl true
  def handle_event(
        "edit",
        %{"item" => project_id},
        %{assigns: %{vm: %{projects: projects}}} = socket
      ) do
    project = Enum.find(projects, &(&1.id == String.to_integer(project_id)))

    popup = %{
      module: Project.Form,
      project: project,
      target: self()
    }

    {:noreply, assign(socket, popup: popup)}
  end

  @impl true
  def handle_event("delete", %{"item" => project_id}, socket) do
    item = dgettext("eyra-project", "delete.confirm")
    title = String.capitalize(dgettext("eyra-ui", "delete.confirm.title", item: item))
    text = String.capitalize(dgettext("eyra-ui", "delete.confirm.text", item: item))
    confirm_label = dgettext("eyra-ui", "delete.confirm.label")

    {
      :noreply,
      socket
      |> assign(project_id: String.to_integer(project_id))
      |> confirm("delete", title, text, confirm_label)
    }
  end

  @impl true
  def handle_event("delete_confirm", _params, %{assigns: %{project_id: project_id}} = socket) do
    Project.Public.delete(project_id)

    {
      :noreply,
      socket
      |> assign(
        project_id: nil,
        dialog: nil
      )
      |> update_view_model()
      |> update_menus()
    }
  end

  @impl true
  def handle_event("delete_cancel", _params, socket) do
    {:noreply, socket |> assign(project_id: nil, dialog: nil)}
  end

  @impl true
  def handle_event("share", %{"item" => project_id}, %{assigns: %{current_user: user}} = socket) do
    researchers =
      Core.Accounts.list_researchers([:profile])
      # filter current user
      |> Enum.filter(&(&1.id != user.id))

    owners =
      project_id
      |> String.to_integer()
      |> Project.Public.get!()
      |> Project.Public.list_owners([:profile])
      # filter current user
      |> Enum.filter(&(&1.id != user.id))

    popup = %{
      module: ShareView,
      content_id: project_id,
      content_name: dgettext("eyra-project", "share.dialog.content"),
      group_name: dgettext("eyra-project", "share.dialog.group"),
      users: researchers,
      shared_users: owners
    }

    {
      :noreply,
      socket |> assign(popup: popup)
    }
  end

  @impl true
  def handle_event("create_project", _params, %{assigns: %{current_user: user}} = socket) do
    user
    |> Project.Public.new_project_name()
    |> Project.Assembly.create(user, :empty)

    {
      :noreply,
      socket
      |> update_view_model()
    }
  end

  @impl true
  def handle_info(%{auto_save: _status}, socket) do
    {
      :noreply,
      socket
    }
  end

  @impl true
  def handle_info({:handle_auto_save_done, :project_overview_popup}, socket) do
    {
      :noreply,
      socket
    }
  end

  @impl true
  def handle_info(%{selector: :cancel}, socket) do
    {
      :noreply,
      socket
      |> assign(selector_dialog: nil)
    }
  end

  @impl true
  def handle_info(%{module: _, action: :close}, socket) do
    {
      :noreply,
      socket
      |> assign(popup: nil)
    }
  end

  @impl true
  def handle_info(
        %{module: Systems.Project.CreatePopup, action: %{redirect_to: node_id}},
        socket
      ) do
    {:noreply, push_redirect(socket, to: ~p"/project/node/#{node_id}")}
  end

  @impl true
  def handle_info(
        %{module: Frameworks.Pixel.ShareView, action: %{add: user, content_id: project_id}},
        socket
      ) do
    project_id
    |> Project.Public.get!()
    |> Project.Public.add_owner!(user)

    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %{module: Frameworks.Pixel.ShareView, action: %{remove: user, content_id: project_id}},
        socket
      ) do
    project_id
    |> Project.Public.get!()
    |> Project.Public.remove_owner!(user)

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.workspace title={dgettext("eyra-project", "overview.title")} menus={@menus}>

      <%= if @popup do %>
        <.popup>
          <div class="mx-10 w-full max-w-popup sm:max-w-popup-sm md:max-w-popup-md lg:max-w-popup-lg">
            <.live_component id={:project_overview_popup} module={@popup.module} {@popup} />
          </div>
        </.popup>
      <% end %>

      <%= if @dialog do %>
        <div class="fixed z-40 left-0 top-0 w-full h-full bg-black bg-opacity-20">
          <div class="flex flex-row items-center justify-center w-full h-full">
            <.plain_dialog {@dialog} />
          </div>
        </div>
      <% end %>

      <%= if @selector_dialog do %>
        <div class="fixed z-40 left-0 top-0 w-full h-full bg-black bg-opacity-20">
          <div class="flex flex-row items-center justify-center w-full h-full">
            <.live_component module={SelectorDialog} id={:selector_dialog} {@selector_dialog} />
          </div>
        </div>
      <% end %>

      <Area.content>
        <Margin.y id={:page_top} />
        <%= if Enum.count(@vm.cards) > 0 do %>
          <div class="flex flex-row items-center justify-center">
            <div class="h-full">
              <Text.title2 margin="">
                <%= dgettext("eyra-project", "overview.header.title") %>
                <span class="text-primary"> <%= Enum.count(@vm.cards) %></span>
              </Text.title2>
            </div>
            <div class="flex-grow">
            </div>
            <div class="h-full pt-2px lg:pt-1">
              <Button.Action.send event="create_project">
                <div class="sm:hidden">
                  <Button.Face.plain_icon label={dgettext("eyra-project", "add.new.button.short")} icon={:forward} />
                </div>
                <div class="hidden sm:block">
                  <Button.Face.plain_icon label={dgettext("eyra-project", "add.new.button")} icon={:forward} />
                </div>
              </Button.Action.send>
            </div>
          </div>
          <Margin.y id={:title2_bottom} />
          <Grid.dynamic>
            <%= for card <- @vm.cards do %>
              <Project.CardView.dynamic card={card} />
            <% end %>
          </Grid.dynamic>
          <.spacing value="L" />
        <% else %>
          <.empty
            title={dgettext("eyra-project", "overview.empty.title")}
            body={dgettext("eyra-project", "overview.empty.description")}
            illustration="cards"
            button={%{
              action: %{type: :send, event: "create_project"},
              face: %{type: :primary, label: dgettext("eyra-project", "add.first.button")}
            }}
          />
        <% end %>
      </Area.content>
    </.workspace>
    """
  end
end
