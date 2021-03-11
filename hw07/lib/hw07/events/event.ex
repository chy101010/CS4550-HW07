defmodule Hw07.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hw07.Users
  alias Hw07.Comments

  schema "events" do
    field :description, :string
    field :date, :utc_datetime
    field :name, :string
    belongs_to :user, Users.User
    has_many :comments, Comments.Comment


    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:name, :date, :description, :user_id])
    |> validate_required([:name, :date, :description, :user_id])
  end
end
