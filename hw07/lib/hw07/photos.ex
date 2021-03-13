# Derived from https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/12-uploads/notes.md
defmodule Hw07Web.Photos do
    
    def save_photo(name, path) do
        # Read the binary data from the path
        data = File.read!(path)
        # Hash
        hash = sha256(data)
        # Storing meta and data
        meta = read_meta(hash)
        save_photo(name, data, hash, meta)
    end
    
    def save_photo(name, data, hash, nil) do
        File.mkdir_p!(base_path(hash))
        meta = %{
          name: name,
          refs: 0,
        }
        save_photo(name, data, hash, meta)
    end
    
      # Note: data race
    def save_photo(name, data, hash, meta) do
        meta = Map.update!(meta, :refs, &(&1 + 1))
        File.write!(meta_path(hash), Jason.encode!(meta))
        File.write!(data_path(hash), data)
        {:ok, hash}
    end
    
    def load_photo(hash) do
        data = File.read!(data_path(hash))
        meta = read_meta(hash)
        {:ok, Map.get(meta, :name), data}
    end
    
    def drop_photo(hash) do
        # TODO: drop_photo
    end

    def read_meta(hash) do
        with {:ok, data} <- File.read(meta_path(hash)),
             {:ok, meta} <- Jason.decode(data, keys: :atoms)
        do
          meta
        else
          _ -> nil
        end
    end
    
    def base_path(hash) do
        Path.expand("~/.local/data/events")
        |> Path.join(String.slice(hash, 0, 2))
        |> Path.join(String.slice(hash, 2, 30))
    end
    
    def data_path(hash) do
        Path.join(base_path(hash), "photo.jpg")
    end
    
    def meta_path(hash) do
        Path.join(base_path(hash), "meta.json")
    end
    
    def sha256(data) do
        :crypto.hash(:sha256, data)
        |> Base.encode16(case: :lower)
    end

    def get_default() do
        photos = Application.app_dir(:hw07, "priv/photo")
        path = Path.join(photos, "default.jpg")
        {:ok, hash} = save_photo("default.jpg", path)
        hash
    end 
end 
