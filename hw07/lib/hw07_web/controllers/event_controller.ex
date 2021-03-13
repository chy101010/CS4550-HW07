# Some of the codes are derived from: https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/13-access-rules/notes.md
defmodule Hw07Web.EventController do
  use Hw07Web, :controller

  alias Hw07.Events
  alias Hw07.Events.Event
  alias Hw07.Comments
  alias Hw07.Invites
  alias Hw07Web.Plugs
  plug Plugs.RequireUser when action in [:new, :edit, :create, :update, :show]
  # User must fully Register to use the site
  plug Plugs.RequireRegistration when action in [:new, :edit, :create, :update, :show]
  # Fetch event to @conn 
  plug :fetch_event when action in [:show, :photo, :edit, :update, :delete]
  # Requires the event owner in update/edit/delete
  plug :require_owner when action in [:edit, :update, :delete]
  # Requires owner and invitee in show
  plug :require_participate when action in [:show]

  def fetch_event(conn, _args) do
    id = conn.params["id"]
    event = Events.get_event!(id)
    assign(conn, :event, event)
  end 

  def require_owner(conn, _args) do
    if is_owner?(conn, conn.assigns[:event].id) do
      conn
    else 
      conn
      |> put_flash(:error, "No access")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def require_participate(conn, _arg) do
    if(belong_to_event?(conn, conn.params["id"])) do
      conn
    else 
      conn
      |> put_flash(:error, "No access")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end 
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
    |> Events.load_invite()
    |> Events.load_user()
    comm = %Comments.Comment{
      event_id: event.id,
      user_id: current_user_id(conn),
    }
    invite = %Invites.Invite{
      event_id: event.id
    }
    invites = Invites.get_invite_by_userid_eventid(current_user_id(conn), id)
    track_invite =
    if(!Enum.empty?(invites)) do
      Invites.change_invite(List.first(invites))
    else 
      nil
    end 
    responses= 
    count_response(event.invites)
    |> Enum.map_join(", ", fn {key, val} -> "#{key}: #{val}" end)
    new_invite = Invites.change_invite(invite)
    new_comment = Comments.change_comment(comm)
    render(conn, "show.html", event: event, responses: responses, new_comment: new_comment, new_invite: new_invite, track_invite: track_invite)
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
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
