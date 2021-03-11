# Some of the codes are derived from: https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/13-access-rules/notes.md
defmodule Hw07Web.EventController do
  use Hw07Web, :controller

  alias Hw07.Events
  alias Hw07.Events.Event
  alias Hw07.Comments
  alias Hw07Web.Plugs
  plug Plugs.RequireUser when action in [:new, :edit, :create, :update]
  plug :fetch_event when action in [:show, :photo, :edit, :update, :delete]
  plug :require_owner when action in [:edit, :update, :delete]

  def fetch_event(conn, _args) do
    id = conn.params["id"]
    event = Events.get_event!(id)
    assign(conn, :event, event)
  end 

  def require_owner(conn, _args) do
    user = conn.assigns[:user]
    post = conn.assigns[:event]

    if user.id == post.user_id do
      conn
    else 
      conn
      |> put_flash(:error, "That isn't yours.")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def index(conn, _params) do
    events = Events.list_events()
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Events.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def dateMap(date) do
    result = 
    %{}
    |> Map.put("month", String.slice(date, 5, 2))
    |> Map.put("day", String.slice(date, 8, 2))
    |> Map.put("year", String.slice(date, 0, 4))
    |> Map.put("hour", String.slice(date, 11, 2))
    |> Map.put("minute", String.slice(date, 14, 2))
    %{"date" => result};
  end

  def create(conn, %{"event" => event_params}) do
    params = 
    event_params
    |> Map.pop("date")
    |> elem(1)
    |> Map.merge(dateMap(Map.get(event_params, "date")))
    |> Map.put("user_id", conn.assigns[:user].id)
    case Events.create_event(params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    event = conn.assigns[:event]
    |> Events.load_comment()
    comm = %Comments.Comment{
      event_id: event.id,
      user_id: current_user_id(conn),
    }
    new_comment = Comments.change_comment(comm);
    render(conn, "show.html", event: event, new_comment: new_comment)
  end

  def edit(conn, %{"id" => id}) do
    event = conn.assigns[:event]
    changeset = Events.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = conn.assigns[:event]
    case Events.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = conn.assigns[:event]
    {:ok, _event} = Events.delete_event(event)
    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end
