defmodule TaskProcessorWeb.TaskController do
  use TaskProcessorWeb, :controller
  alias TaskProcessor.CommandTask

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, %{"tasks" => tasks}) do
    case CommandTask.sort(tasks) do
      {:ok, sorted_tasks} ->
        render(conn, "tasks.json", tasks: sorted_tasks)

      {:error, message} ->
        conn
        |> put_view(TaskProcessorWeb.ErrorView)
        |> render("error.json", message: message)
    end
  end
end
