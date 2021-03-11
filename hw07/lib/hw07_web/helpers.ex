# Code Derived From: https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/13-access-rules/notes.md
defmodule Hw07Web.Helpers do
    def have_user?(conn) do
        conn.assigns[:user] != nil
    end 

    def have_current_user?(conn) do
        conn.assigns[:user] != nil
    end

    def current_user_id(conn) do
        user = conn.assigns[:user]
        user && user.id
    end
end 