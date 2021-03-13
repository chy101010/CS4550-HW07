defmodule Hw07Web.CommentController do
  use Hw07Web, :controller

  alias Hw07.Comments
  alias Hw07.Comments.Comment
  alias Hw07.Events
  alias Hw07.Invites
  alias Hw07Web.Plugs
  plug Plugs.RequireUser when action in [:edit, :create, :update]
  # Assign the comment to #conn
  plug :fetch_comment when action in [:edit, :update, :delete]
  # Only Commenter and Owner can edit/update/delete a comment
  plug :require_commenter_access when action in [:edit, :update, :delete]
  # Assign the associate event to #conn
  plug :fetch_event when action in [:delete, :update]

  def fetch_comment(conn, _arg) do
    id = conn.params["id"]
    comment = Comments.get_comment!(id)
    assign(conn, :comment, comment)
  end 

  def fetch_event(conn, _arg) do
    event = Events.get_event!(conn.assigns[:comment].event_id)
    assign(conn, :event, event)
  end  

  def require_commenter_access(conn, _arg) do
    id = conn.params["id"]
    if(is_commenter?(conn, id)) do
      conn 
    else 
      conn
      |> put_flash(:error, "No access")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end 
  end 

  # Access: Event owner and invitees
  def new(conn, _params) do
    changeset = Comments.change_comment(%Comment{})
    render(conn, "new.html", changeset: changeset)
  end

  # Access: Event owner and invitees
  def create(conn, %{"comment" => comment_params}) do
    event_id = comment_params["event_id"]
    current_user_id = conn.assigns[:user].id
    cond do
      String.length(String.trim(event_id)) == 0 -> 
        conn 
        |> put_flash(:error, "Select An Event")
        |> redirect(to: Routes.page_path(conn, :index))
      belong_to_event?(conn, event_id) ->
        comment_params = comment_params
        |> Map.put("user_id", current_user_id(conn))
        case Comments.create_comment(comment_params) do
          {:ok, comment} ->
            event = Events.get_event!(event_id)
            conn
            |> put_flash(:info, "Comment created successfully.")
            |> redirect(to: Routes.event_path(conn, :show, event))
          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset)
        end
      true ->
        conn
        |> put_flash(:error, "No access")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  # Access: Event Owner and Invitee who created the comment
  def edit(conn, %{"id" => id}) do
    comment = conn.assigns[:comment]
    changeset = Comments.change_comment(comment)
    render(conn, "edit.html", comment: comment, changeset: changeset)
  end

  # Access: Event Owner and Invitee who created the comment
  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = conn.assigns[:comment]
    event = conn.assigns[:event]
    case Comments.update_comment(comment, comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", comment: comment, changeset: changeset)
    end
  end

  # Access: Event Owner and Invitee who created the comment 
  def delete(conn, %{"id" => id}) do
    comment = conn.assigns[:comment]
    event = conn.assigns[:event]
    {:ok, _comment} = Comments.delete_comment(comment)
    conn
    |> put_flash(:info, "Comment deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :show, event))
  end
end
