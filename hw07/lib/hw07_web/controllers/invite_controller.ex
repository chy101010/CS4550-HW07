defmodule Hw07Web.InviteController do
  use Hw07Web, :controller

  alias Hw07.Invites
  alias Hw07.Invites.Invite
  alias Hw07.Users
  alias Hw07Web.Plugs
  alias Hw07.Events
  plug Plugs.RequireUser when action in [:create, :show, :edit, :update, :delete]
  # User must fully Register to use the site
  plug Plugs.RequireRegistration when action in [:create, :edit, :update, :delete]
  # Fetch invite to @conn 
  plug :fetch_invite when action in [:show, :edit, :update, :delete]
  # Fetch event to @conn 
  plug :fetch_event when action in [:show, :edit, :update, :delete]

  # Fetch the invite 
  def fetch_invite(conn, _params) do
    id = conn.params["id"]
    invite = Invites.get_invite!(id)
    assign(conn, :invite, invite)
  end 

  # Fetch the event associated to the current invite
  def fetch_event(conn, _params) do
    id = conn.params["id"]
    event = Events.get_event!(conn.assigns[:invite].event_id)
    assign(conn, :event, event)
  end 

  # Access: Event Owner
  def create(conn, %{"invite" => invite_params}) do
    event_id = invite_params["event_id"]
    user_id = conn.assigns[:user].id
    event = Events.get_event!(event_id)
    # Checking if there is an associated event
    if(String.length(String.trim(event_id)) == 0) do
      conn
      |> put_flash(:error, "Something Went Wrong")
      |> redirect(to: Routes.page_path(conn, :index))
    else 
      # Checking if the current user if the owner of the event 
      {user_email, invite_params} = Map.pop(invite_params, "user_email")
      if(is_owner?(conn, event_id) && conn.assigns[:user].email != user_email) do
        get_user = Users.get_user_by_email(user_email)
        user = 
        if(!get_user) do
          # Create User 
          {result, user} = Users.create_user(%{"email" => user_email})
          if(result == :error) do
            conn
            |> put_flash(:error, "Something Went Wrong, Email Format?")
            |> redirect(to: Routes.event_path(conn, :show, event))
          else 
            user
          end
        else
          get_user
        end 
        IO.inspect(user)
        invite_params = Map.put(invite_params, "user_id", user.id)
        case Invites.create_invite(invite_params) do
          {:ok, invite} ->
            conn
            |> put_flash(:info, "Invitee Created - Note: Unknown User Need to Finish Registration!")
            |> redirect(to: Routes.event_path(conn, :show, event))
          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_flash(:error, "Something Went Wrong!")
            |> redirect(to: Routes.event_path(conn, :show, event))
        end 
      else 
        conn
        |> put_flash(:error, "No Access")
        |> redirect(to: Routes.event_path(conn, :show, event))
      end
    end 
  end

  # Access: Invitees
  def show(conn, %{"id" => id}) do
    user_id = conn.assigns[:user].id
    invite = conn.assigns[:invite]
    if(user_id == invite.user_id) do
      render(conn, "show.html", invite: invite)
    else
      conn
      |> put_flash(:error, "No Access")
      |> redirect(to: Routes.page_path(conn, :index))
    end 
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
  def update(conn, %{"id" => id, "invite" => invite_params}) do
    user_id = conn.assigns[:user].id
    invite = conn.assigns[:invite]
    event = conn.assigns[:event]
    if(user_id == invite.user_id) do 
      case Invites.update_invite(invite, invite_params) do
        {:ok, invite} ->
          conn
          |> put_flash(:info, "Invite updated successfully.")
          |> redirect(to: Routes.event_path(conn, :show, event))

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
    IO.puts("called")
    IO.inspect(event)
    if(event && event.user_id == user_id) do
      invite = conn.assigns[:invite]
      {:ok, _invite} = Invites.delete_invite(invite)
      conn
      |> put_flash(:info, "Invite deleted successfully.")
      |> redirect(to: Routes.event_path(conn, :show, event))
    else
      conn
      |> put_flash(:error, "No Access")
      |> redirect(to: Routes.page_path(conn, :index))
    end 
  end
end
