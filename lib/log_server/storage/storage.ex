defmodule LogServer.Storage do
  @moduledoc false
  alias LogServer.Tools
  alias LogServer.Storage.S3
  alias LogServer.Storage.MetadataCache
  @cache_folder(
    if System.get_env("DEV"),
      do: "cache",
      else: "../data/cache"
  )

  def upload(storage_path) do
    S3.upload(storage_path)
  end

  def download(storage_path) do
    [project, time_shard, type_file, key_shard] = Tools.split_storage_path(storage_path)
    dest_path =
      [@cache_folder]
      |> Kernel.++([project, time_shard, type_file, key_shard])
      |> Path.join()

    if File.exists?(dest_path) do
      {:ok, dest_path}
    else
      [@cache_folder]
      |> Kernel.++([project, time_shard, type_file])
      |> Path.join()
      |> File.mkdir_p!()

      S3.download(storage_path, dest_path)
    end
  end
end
