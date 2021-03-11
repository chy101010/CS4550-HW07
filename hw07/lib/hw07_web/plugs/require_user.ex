# Code Derived From: https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/13-access-rules/notes.md
defmodule Hw07Web.Plugs.RequireUser do 
    use Hw07Web, :controller

    def init(args), do: args

    def call(conn, _args) do
        if conn.assigns[:user] do
            conn
        else 
            conn 
            |> put_flash(:error, "Login required")
            |> redirect(to: Routes.page_path(conn, :index))
            |> halt()
        end 
    end 
end 