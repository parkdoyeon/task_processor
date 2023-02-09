defmodule TaskProcessor.CommandTask do
  @moduledoc """
  This module handles operation of sorting tasks in order.
  To avoid confusion from Elixir.Task, I named this module CommandTask.
  """

  defp parse(task) do
    %{
      name: Map.get(task, "name"),
      command: Map.get(task, "command"),
      requires: Map.get(task, "requires"),
      # for removing task in sorted list
      temp_requires: Map.get(task, "requires", [])
    }
  end

  defp find_priority(tasks) do
    {tasks, Enum.filter(tasks, &(Map.get(&1, :temp_requires) == []))}
  end

  defp process_priority({[], _priority_tasks}, sorted_tasks), do: {:ok, sorted_tasks}

  defp process_priority({_tasks, []}, _sorted_tasks),
    do: {:error, "Task not able to process exists, check `requires`"}

  defp process_priority({tasks, priority_tasks}, sorted_tasks) do
    priority_task_names = Enum.map(priority_tasks, &Map.get(&1, :name))

    processed_tasks =
      tasks
      |> Enum.reject(&(&1.temp_requires == []))
      |> Enum.map(
        &Map.update(&1, :temp_requires, [], fn rs ->
          rs -- priority_task_names
        end)
      )

    {processed_tasks, sorted_tasks ++ priority_tasks}
  end

  @spec sort([%{}]) :: {:error, [%{}]} | {:ok, [%{}]}
  @doc """
  Topological Sort
  1. Find priority tasks; priority task is one that doesn't have any requires
  2. Process priority tasks
    2-1. Remove priority tasks from tasks and other tasks' requires
    2-2. Append priority tasks to sorted task list
  3. Iterate 1-2 until every tasks are sorted
  """
  def sort(tasks) do
    {Enum.map(tasks, &parse/1), []}
    |> Stream.iterate(fn {tasks, sorted_task} ->
      tasks
      |> find_priority()
      |> process_priority(sorted_task)
    end)
    |> Enum.find(&is_atom(elem(&1, 0)))
  end
end
