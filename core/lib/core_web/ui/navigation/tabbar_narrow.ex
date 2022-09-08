defmodule CoreWeb.UI.Navigation.TabbarNarrow do
  @moduledoc false
  use CoreWeb.UI.LiveComponent

  alias CoreWeb.UI.Navigation.{TabbarDropdown, TabbarItem}

  data(tabs, :any, from_context: :tabs)

  def render(assigns) do
    ~F"""
    <div>
      <div id="tabbar_dropdown" class="absolute z-50 left-0 top-navbar-height w-full h-full">
        <TabbarDropdown />
      </div>
      <div
        id="tabbar_narrow"
        phx-hook="Toggle"
        target="tabbar_dropdown"
        class="flex flex-row cursor-pointer items-center h-full w-full"
      >
        <div class="flex-shrink-0">
          {#for {tab, index} <- Enum.with_index(@tabs)}
            <div class="flex-shrink-0">
              <TabbarItem tabbar="narrow" opts="hide-when-idle" vm={Map.merge(tab, %{index: index})} />
            </div>
          {/for}
        </div>
        <div class="flex-grow">
        </div>
        <div>
          <img src="/images/icons/dropdown.svg" alt="Show tabbar dropdown">
        </div>
      </div>
    </div>
    """
  end
end
