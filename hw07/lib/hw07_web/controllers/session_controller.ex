defmodule Hw07Web.SessionController do
  use Hw07Web, :controller

  # Starter Code From Lecture
  def create(conn, %{"email" => email}) do
    user = Hw07.Users.get_user_by_email(email);
    if(user) do 
        msg =
        if(user == nil) do
          "Need to complete the registration by entering a name, before exploring the site!"
        else 
          "Welcome Back #{user.name}"
        end 
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, msg)
        |> redirect(to: Routes.page_path(conn, :index))
    else
        conn
        |> put_flash(:error, "Invalide Email")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Logged out")
    |> redirect(to: Routes.page_path(conn, :index))
  end


end 