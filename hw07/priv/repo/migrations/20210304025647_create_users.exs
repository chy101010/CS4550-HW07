defmodule Hw07.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: true
      add :email, :string, null: false
      add :photo_hash, :text, null: true

      timestamps()
    end
    
    create unique_index(:users, [:email])
  end
end
