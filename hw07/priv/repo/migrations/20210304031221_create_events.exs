defmodule Hw07.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string, null: false
      add :date, :utc_datetime, null: false
      add :description, :string
      add :user_id, references(:users, on_delete: :delete_all), null: false
      
      timestamps()
    end

  end
end
