defmodule Hw07Web.PageController do
  use Hw07Web, :controller

  def index(conn, _params) do
    events = Hw07.Events.list_events()
    render(conn, "index.html", events: events);
  end
end
