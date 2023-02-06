defmodule TaskProcessorWeb.TaskControllerTest do
  use TaskProcessorWeb.ConnCase

  describe "index" do
    test "Return sorted tasks", %{conn: conn} do
      tasks = [
        %{"name" => "task-1", "command" => "touch /tmp/file1", "requires" => []},
        %{"name" => "task-2", "command" => "cat /tmp/file1", "requires" => ["task-3"]},
        %{
          "name" => "task-3",
          "command" => "echo 'Hello Word!' > /tmp/file1",
          "requires" => ["task-1"]
        },
        %{"name" => "task-4", "command" => "rm /tmp/file1", "requires" => ["task-2", "task-3"]}
      ]

      conn = post(conn, Routes.task_path(conn, :index), tasks: tasks)

      assert %{
               "tasks" => [
                 %{"name" => "task-1", "command" => "touch /tmp/file1", "requires" => []},
                 %{
                   "name" => "task-3",
                   "command" => "echo 'Hello Word!' > /tmp/file1",
                   "requires" => ["task-1"]
                 },
                 %{"name" => "task-2", "command" => "cat /tmp/file1", "requires" => ["task-3"]},
                 %{
                   "name" => "task-4",
                   "command" => "rm /tmp/file1",
                   "requires" => ["task-2", "task-3"]
                 }
               ]
             } == json_response(conn, 200)
    end

    test "Show error message if task is not able to be processed", %{conn: conn} do
      tasks = [
        %{"name" => "task-1", "command" => "touch /tmp/file1", "requires" => []},
        %{"name" => "impossible-task", "command" => "cat /tmp/file1", "requires" => ["task-3"]}
      ]

      conn = post(conn, Routes.task_path(conn, :index), tasks: tasks)

      assert %{"error" => %{"detail" => message}} = json_response(conn, 200)
      assert message =~ "Unable"
    end
  end

  describe "bash" do
    test "Return ordered task commands successfully", %{conn: conn} do
      tasks = [
        %{"name" => "task-1", "command" => "touch /tmp/file1", "requires" => []},
        %{"name" => "task-2", "command" => "cat /tmp/file1", "requires" => ["task-3"]},
        %{
          "name" => "task-3",
          "command" => "echo 'Hello Word!' > /tmp/file1",
          "requires" => ["task-1"]
        },
        %{"name" => "task-4", "command" => "rm /tmp/file1", "requires" => ["task-2", "task-3"]}
      ]

      conn = post(conn, Routes.task_path(conn, :bash), tasks: tasks)

      assert "touch /tmp/file1$'\necho 'Hello Word!' > /tmp/file1$'\ncat /tmp/file1$'\nrm /tmp/file1" ==
               text_response(conn, 200)
    end

    test "Show error message  if task is not able to be processed", %{conn: conn} do
      tasks = [
        %{"name" => "task-1", "command" => "touch /tmp/file1", "requires" => []},
        %{"name" => "impossible-task", "command" => "cat /tmp/file1", "requires" => ["task-3"]}
      ]

      conn = post(conn, Routes.task_path(conn, :bash), tasks: tasks)

      assert %{"error" => %{"detail" => message}} = json_response(conn, 200)
      assert message =~ "Unable"
    end
  end
end
