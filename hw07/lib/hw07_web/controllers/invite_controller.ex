defmodule Hw07Web.InviteController do
  use Hw07Web, :controller

  alias Hw07.Invites
  alias Hw07.Invites.Invite
  alias Hw07.Users
  alias Hw07Web.Plugs
  alias Hw07.Events
  plug Plugs.RequireUser when action in [:new, :edit, :create, :update, :show]
  plug :fetch_invite when action in [:show, :edit, :update, :delete]
  plug :fetch_event when action in [:show, :photo, :edit, :update, :delete]

  # Fetch the invite 
  def fetch_invite(conn, _params) do
    id = conn.params["id"]
    invite = Invites.get_invite!(id)
    assign(conn, :invite, invite)
  end 

  # Fetch the event associated to the current invite
  def fetch_event(conn, _params) do
    id = conn.params["id"]
    event = Invites.get_event_by_inviteid(id)
    assign(conn, :event, event)
  end 

  def new(conn, params) do
    changeset = Invites.change_invite(%Invite{})
    render(conn, "new.html", changeset: changeset)
  end

  # TODO: Link
  def create(conn, %{"invite" => invite_params}) do
    event_id = invite_params["event_id"]
    current_user_id = conn.assigns[:user].id
    # Checking if there is an associated event
    if(String.length(String.trim(event_id)) == 0) do
      conn
      |> put_flash(:error, "Select An Event")
      |> redirect(to: Routes.page_path(conn, :index))
    else 
      # Checking if the current user if the owner of the event 
      if(is_owner?(conn, event_id)) do
        {user_email, invite_params} = Map.pop(invite_params, "user_email")
        user = Users.get_user_by_email(user_email)
        if(user) do 
          id = user.id
          invite_params = Map.put(invite_params, "user_id", id)
          case Invites.create_invite(invite_params) do
            {:ok, invite} ->
              event = Events.get_event!(event_id)
              message = "Invite Link: http://events.citronk.com/invites/" <> Integer.to_string(invite.id)
              conn
              |> put_flash(:info, message)
              |> redirect(to: Routes.event_path(conn, :show, event))
            {:error, %Ecto.Changeset{} = changeset} ->
              render(conn, "new.html", changeset: changeset)
          end 
        else 
          conn
          |> put_flash(:error, "Not An User") 
          |> redirect(to: Routes.page_path(conn, :index))
        end
      else 
        conn
        |> put_flash(:error, "No Access")
        |> redirect(to: Routes.page_path(conn, :index))
      end
    end 
  end

  def show(conn, %{"id" => id}) do
    invite = conn.assigns[:invite]
    render(conn, "show.html", invite: invite)
  end

  # Access: Invitees
  def edit(conn, %{"id" => id}) do
    user_id = conn.assigns[:user].id
    invite = conn.assigns[:invite]
    if(user_id == invite.user_id) do
      changeset = Invites.change_invite(invite)
      render(conn, "edit.html", invite: invite, changeset: changeset)
    else 
      conn
      |> put_flash(:error, "No Access")
      |> redirect(to: Routes.page_path(conn, :index))
    end 
  end

  # Access: Invitess 
  # TODO: Only Response
  def update(conn, %{"id" => id, "invite" => invite_params}) do
    user_id = conn.assigns[:user].id
    invite = conn.assigns[:invite]
    if(user_id == invite.user_id) do 
      case Invites.update_invite(invite, invite_params) do
        {:ok, invite} ->
          conn
          |> put_flash(:info, "Invite updated successfully.")
          |> redirect(to: Routes.invite_path(conn, :show, invite))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", invite: invite, changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "No Access")
      |> redirect(to: Routes.page_path(conn, :index))
    end  
  end

  # Require owner of the event
  def delete(conn, %{"id" => id}) do
    user_id = conn.assigns[:user].id
    event = conn.assigns[:event]
    if(event && List.first(event).user_id == user_id) do
      invite = conn.assigns[:invite]
      {:ok, _invite} = Invites.delete_invite(invite)
      conn
      |> put_flash(:info, "Invite deleted successfully.")
      |> redirect(to: Routes.page_path(conn, :index))
    else
      conn
      |> put_flash(:error, "No Access")
      |> redirect(to: Routes.page_path(conn, :index))
    end 
  end
end
