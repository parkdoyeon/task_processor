defmodule TaskProcessorWeb.TaskView do
  use TaskProcessorWeb, :view

  def render("task.json", %{task: task}) do
    %{name: task.name, command: task.command, requires: task.requires}
  end

  def render("tasks.json", %{tasks: tasks}) do
    %{tasks: render_many(tasks, __MODULE__, "task.json")}
  end
end
