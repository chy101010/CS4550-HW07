defmodule Hw07Web.PageController do
  use Hw07Web, :controller

  def index(conn, _params) do
    users = Hw07.Users.list_users();
    events = Hw07.Events.list_events()
    render(conn, "index.html", events: events, users: users);
  end
end
