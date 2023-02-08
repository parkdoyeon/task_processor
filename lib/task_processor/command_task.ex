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
      temp_requires: Map.get(task, "requires", []) # for removing task put in the list
    }
  end

  defp find_priory(tasks) do
    {tasks, Enum.filter(tasks, &(Map.get(&1, :temp_requires) == []))}
  end

  defp process_priory({[], _priory_tasks}, sorted_tasks), do: {:ok, sorted_tasks}

  defp process_priory({_tasks, []}, _sorted_tasks),
    do: {:error, "Task not able to process exists, check `requires`"}

  defp process_priory({tasks, priory_tasks}, sorted_tasks) do
    priory_task_names = Enum.map(priory_tasks, &Map.get(&1, :name))

    processed_tasks =
      tasks
      |> Enum.reject(&(&1.temp_requires == []))
      |> Enum.map(
        &Map.update(&1, :temp_requires, [], fn rs ->
          rs -- priory_task_names
        end)
      )

    {processed_tasks, sorted_tasks ++ priory_tasks}
  end

  @spec sort([%{}]) :: {:error, [%{}]} | {:ok, [%{}]}
  @doc """
  Topological Sort
  1. Find priory tasks; priory task is one that doesn't have any requires
  2. Process priory tasks
    2-1. Remove priory tasks from tasks and other tasks' requires
    2-2. Append priory tasks to sorted task list
  3. Iterate 1-2 until every tasks are sorted
  """
  def sort(tasks) do
    {Enum.map(tasks, &parse/1), []}
    |> Stream.iterate(fn {tasks, sorted_task} ->
      tasks
      |> find_priory()
      |> process_priory(sorted_task)
    end)
    |> Enum.find(&is_atom(elem(&1, 0)))
  end
end
