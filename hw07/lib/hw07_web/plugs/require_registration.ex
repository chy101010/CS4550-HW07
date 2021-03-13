defmodule Hw07Web.Plugs.RequireRegistration do 
    use Hw07Web, :controller
    def init(args), do: args

    def call(conn, _args) do
        if conn.assigns[:user].name != nil do
            conn
        else 
            conn 
            |> put_flash(:error, "Require Complete Registration")
            |> redirect(to: Routes.page_path(conn, :index))
            |> halt()
        end 
    end 
end 