defmodule Hw07.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites) do
      add :response, :string, default: ""
      add :event_id, references(:events, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:invites, [:event_id, :user_id])
    # create index(:invites, [:event_id])
    # create index(:invites, [:user_id])
  end
end
