defmodule Hw07.Invites.Invite do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hw07.Events
  alias Hw07.Users

  schema "invites" do
    field :response, :string, default: "unresponded"
    belongs_to :event, Events.Event
    belongs_to :user,  Users.User
    # field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(invite, attrs) do
    invite
    |> cast(attrs, [:response, :event_id, :user_id])
    |> unique_constraint(:user_id)
    |> validate_required([:response, :event_id, :user_id])
  end
end
