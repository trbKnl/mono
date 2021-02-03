defmodule EyraUI.Form.NumberInput
do
  use Surface.Component
  alias Surface.Components.Form.NumberInput
  alias EyraUI.Form.Field

  prop field, :atom, required: true
  prop label_text, :string

  def render(assigns) do
    ~H"""
    <Field field={{@field}} label_text={{@label_text}}>
      <NumberInput field={{@field}} opts={{class: "text-grey1 text-bodymedium font-body pl-3 w-full border-2 border-solid border-grey3 focus:outline-none focus:border-primary rounded h-44px"}} />
    </Field>
    """
  end
end
