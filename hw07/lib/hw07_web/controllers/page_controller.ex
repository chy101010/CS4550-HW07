defmodule Hw07Web.PageController do
  use Hw07Web, :controller
  alias Hw07.Events

  def index(conn, _params) do
    if(conn.assigns[:user] != nil) do
      id = conn.assigns[:user].id
      owned_events = Events.get_events_owned(id)
      invited_events = Events.get_events_invited(id)
      render(conn, "index.html", owned_events: owned_events, invited_events: invited_events)
    else
      render(conn, "index.html");
    end 
  end
end
