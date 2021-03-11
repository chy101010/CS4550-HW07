## Starter Code From lecture
defmodule Hw07Web.Plugs.FetchSession do
    use Hw07Web, :controller

    def init(args), do: args

    def call(conn, _args) do
        user = Hw07.Users.get_user(get_session(conn, :user_id) || -1);
        if(user) do
            assign(conn, :user, user);
        else 
            assign(conn, :user, nil);
        end 
    end 
end 