defmodule TaskProcessor.CommandTask do
  defp parse(task) do
    %{
      name: Map.get(task, "name"),
      command: Map.get(task, "command"),
      requires: Map.get(task, "requires"),
      temp_requires: Map.get(task, "requires", [])
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
      |> Enum.reject(&match?(%{temp_requires: []}, &1))
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
  1. Find priory task; priory task is the one that doesn't have any requires
  2. Remove priory task's name from rest task's requires and remove itself from the tasks
  3. Add priory task to sorted task list until every tasks are sorted
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
