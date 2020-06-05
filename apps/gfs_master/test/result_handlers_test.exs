alias Algae.Either

defmodule GFSMaster.ResultHandlers.Test do
  use ExUnit.Case
  use Witchcraft.Functor

  test "it should pipe the result to the end if there are no handlers" do
    result = Either.Right.new()
    assert result == result |> GFSMaster.ResultHandlers.pipe([]).()
  end

  test "it should pipe the result to the end if no handlers match" do
    result = Either.Right.new()

    assert result ==
             result
             |> GFSMaster.ResultHandlers.pipe([
               fn x -> x end,
               fn x -> x end
             ]).()
  end

  test "it should return the result of the first handler than matches" do
    result = Either.Right.new()
    handled_result = {:ok}

    assert handled_result ==
             result
             |> GFSMaster.ResultHandlers.pipe([
               fn _ -> handled_result end,
               fn x -> x end
             ]).()
  end

  test "handles success" do
    result = Either.Right.new()
    {201} = result |> GFSMaster.ResultHandlers.handle_success(201).()
  end

  test "handles validation errors" do
    result = %Either.Left{left: {:error_validation, []}}

    {400, %GFSMaster.DTO.ValidationError{}} =
      result |> GFSMaster.ResultHandlers.handle_validation_error().()
  end

  test "handles file already exists" do
    result = %Either.Left{left: {:file_already_exists, "aaa"}}

    {400, %GFSMaster.DTO.FileAlreadyExistError{}} =
      result |> GFSMaster.ResultHandlers.handle_file_already_exists_error().()
  end

  test "handles parent are not directories" do
    result = %Either.Left{left: {:parents_are_not_directories, []}}

    {400, %GFSMaster.DTO.ParentsAreNotDirectoriesError{}} =
      result |> GFSMaster.ResultHandlers.handle_parents_are_not_directories().()
  end

  test "handles missing parent directories" do
    result = %Either.Left{left: {:missing_parents_dirs, []}}

    {400, %GFSMaster.DTO.MissingDirectoriesError{}} =
      result |> GFSMaster.ResultHandlers.handle_missing_directories().()
  end
end
