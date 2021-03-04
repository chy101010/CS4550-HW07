defmodule Hw07Web.EventController do
  use Hw07Web, :controller

  alias Hw07.Events
  alias Hw07.Events.Event

  def index(conn, _params) do
    events = Events.list_events()
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Events.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def minute(date) do
    if(String.slice(date, 15, 2) == "AM") do
      String.slice(date, 9, 2);
    else
      Integer.to_string(12 + String.to_integer(String.slice(date, 9, 2)));
    end
  end

  def dateMap(date) do
    result = 
    %{}
    |> Map.put("month", String.slice(date, 0, 2))
    |> Map.put("day", String.slice(date, 3, 2))
    |> Map.put("year", "20" <> String.slice(date, 6, 2))
    |> Map.put("hour", minute(date))
    |> Map.put("minute", String.slice(date, 12, 2))
    %{"date" => result};
  end

  def create(conn, event_params) do
    params = Map.merge(dateMap(Map.get(event_params, "date")), Map.get(event_params, "event"));
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
    event = Events.get_event!(id)
    render(conn, "show.html", event: event)
  end

  def edit(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    changeset = Events.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Events.get_event!(id)

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
    event = Events.get_event!(id)
    {:ok, _event} = Events.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end
