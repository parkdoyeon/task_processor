defmodule TaskProcessor.CommandTaskTest do
  use ExUnit.Case
  alias TaskProcessor.CommandTask

  test "Return tasks in order" do
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

    assert {:ok, ret_tasks} = CommandTask.sort(tasks)

    assert [%{name: "task-1"}, %{name: "task-3"}, %{name: "task-2"}, %{name: "task-4"}] =
             ret_tasks
  end

  test "Return single valid task" do
    tasks = [%{"name" => "task-1", "command" => "touch /tmp/file1", "requires" => []}]

    assert {:ok, ret_tasks} = CommandTask.sort(tasks)
    assert [%{name: "task-1"}] = ret_tasks
  end

  test "Return error when task dependencies are circular" do
    tasks = [
      %{"name" => "task-1", "command" => "touch /tmp/file1", "requires" => ["task-2"]},
      %{"name" => "task-2", "command" => "cat /tmp/file1", "requires" => ["task-3"]},
      %{
        "name" => "task-3",
        "command" => "echo 'Hello Word!' > /tmp/file1",
        "requires" => ["task-1"]
      }
    ]

    assert {:error, message} = CommandTask.sort(tasks)
    assert message =~ "not able to process"
  end

  test "Return error when there's task not able to process" do
    tasks = [
      %{"name" => "task-1", "command" => "touch /tmp/file1", "requires" => []},
      %{"name" => "impossible-task", "command" => "cat /tmp/file1", "requires" => ["task-9"]},
      %{
        "name" => "task-3",
        "command" => "echo 'Hello Word!' > /tmp/file1",
        "requires" => ["task-1"]
      }
    ]

    assert {:error, message} = CommandTask.sort(tasks)
    assert message =~ "not able to process"
  end
end
