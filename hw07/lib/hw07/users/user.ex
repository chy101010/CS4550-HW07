defmodule Hw07.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hw07.Events
  alias Hw07.Comments

  schema "users" do
    field :email, :string
    field :name, :string
    field :photo_hash, :string
    has_many :events, Events.Event 
    has_many :comments, Comments.Comment

    timestamps()
  end

  @doc false
  # Regrex format is pulled from https://gist.github.com/mgamini/4f3a8bc55bdcc96be2c6
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :photo_hash])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i)
  end
end
