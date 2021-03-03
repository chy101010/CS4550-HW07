defmodule Hw07Web.PageController do
  use Hw07Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
