defmodule GFSMaster.ResultHandlers do
  alias Algae.Either
  alias GFSMaster.DTO

  @spec pipe(list()) :: any
  def pipe(handlers) do
    fn result ->
      Enum.reduce(handlers, result, fn handler, acc ->
        case result do
          %Either.Right{} -> handler.(acc)
          %Either.Left{} -> handler.(acc)
          _ -> acc
        end
      end)
    end
  end

  @spec handle_success(number()) :: (Either -> any)
  def handle_success(code) do
    fn result ->
      case result do
        %Either.Right{} -> {code}
        _ -> result
      end
    end
  end

  @spec handle_validation_error :: (any -> any)
  def handle_validation_error do
    fn result ->
      case result do
        %Either.Left{left: {:error_validation, errors}} ->
          {400, DTO.ValidationError.new(errors)}

        _ ->
          result
      end
    end
  end

  @spec handle_file_already_exists_error :: (any -> any)
  def handle_file_already_exists_error do
    fn result ->
      case result do
        %Either.Left{left: {:file_already_exists, file_path}} ->
          {400, DTO.FileAlreadyExistError.new(file_path)}

        _ ->
          result
      end
    end
  end

  @spec handle_parents_are_not_directories :: (any -> any)
  def handle_parents_are_not_directories do
    fn result ->
      case result do
        %Either.Left{left: {:parents_are_not_directories, invalid_directories}} ->
          {400, DTO.ParentsAreNotDirectoriesError.new(invalid_directories)}

        _ ->
          result
      end
    end
  end

  @spec handle_missing_directories :: (any -> any)
  def handle_missing_directories do
    fn result ->
      case result do
        %Either.Left{left: {:missing_parents_dirs, missing_directories}} ->
          {400,
           %{
             "error" => %{
               "message" => "file is missing parent directories",
               "missing_directories" => missing_directories
             }
           }}

        _ ->
          result
      end
    end
  end
end
