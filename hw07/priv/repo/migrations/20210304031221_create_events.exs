defmodule Hw07.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :name, :string, null: false
      add :date, :date, null: false
      add :description, :string

      timestamps()
    end

  end
end
