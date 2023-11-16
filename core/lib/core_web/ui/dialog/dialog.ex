defmodule CoreWeb.UI.Dialog do
  use CoreWeb, :html

  alias Frameworks.Pixel.Button

  attr(:title, :string, required: true)
  attr(:text, :string, required: true)
  attr(:buttons, :list, default: [])
  slot(:inner_block)

  def dialog(assigns) do
    ~H"""
    <div class="p-8 bg-white shadow-2xl min-w-dialog-width sm:min-w-dialog-width-sm rounded">
      <div class="flex flex-col gap-4 sm:gap-8">
        <div class="text-title5 font-title5 sm:text-title3 sm:font-title3">
          <%= @title %>
        </div>
        <div class="text-bodymedium font-body sm:text-bodylarge">
          <%= @text %>
        </div>
        <div>
          <%= render_slot(@inner_block) %>
        </div>
        <div class="flex flex-row gap-4">
          <%= for button <- @buttons do %>
            <Button.dynamic {button} />
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
