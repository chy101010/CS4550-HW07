defmodule Hw07.Comments.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hw07.Users
  alias Hw07.Events

  schema "comments" do
    field :body, :string
    belongs_to :event, Events.Event
    belongs_to :user, Users.User

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :event_id, :user_id])
    |> validate_required([:body, :event_id, :user_id])
  end
end
