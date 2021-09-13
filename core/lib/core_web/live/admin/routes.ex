defmodule CoreWeb.Live.Admin.Routes do
  defmacro routes() do
    quote do
      scope "/admin", CoreWeb.Admin do
        pipe_through([:browser])

        live("/login", Login)
        live("/permissions", Permissions)
        live("/support", Support)
      end
    end
  end
end