defmodule GFSMaster.Database.CreateFile.Test do
  use ExUnit.Case
  alias Algae.Either
  alias GFSMaster.Database.FileMetadata

  setup _context do
    :ok = Amnesia.start()
    GFSMaster.Database.create()
    :ok = GFSMaster.Database.wait()

    on_exit(fn ->
      GFSMaster.Database.destroy()
      Amnesia.stop()
      Amnesia.Schema.destroy()
    end)
  end

  test "it should be able to create a file" do
    %Either.Right{} = FileMetadata.create_file("aaa", false)
  end

  test "it not create a file twice" do
    %Either.Right{} = FileMetadata.create_file("aaa", false)
    %Either.Left{left: {:file_already_exists, _}} = FileMetadata.create_file("aaa", false)
  end

  test "it should be able to create a directory" do
    %Either.Right{} = FileMetadata.create_file("aaa", true)
  end

  test "it should be able to create a file nested under a directory" do
    %Either.Right{} = FileMetadata.create_file("aaa", true)
    %Either.Right{} = FileMetadata.create_file("aaa/aaa", false)
  end

  test "it should fail to create a file not nested under a directory" do
    %Either.Left{left: {:missing_parents_dirs, _}} = FileMetadata.create_file("aaa/aaa", false)
  end

  test "it should fail to create a file if one of its parents is not a directory" do
    %Either.Right{} = FileMetadata.create_file("aaa", false)

    %Either.Left{left: {:parents_are_not_directories, _}} =
      FileMetadata.create_file("aaa/aaa", false)
  end
end
