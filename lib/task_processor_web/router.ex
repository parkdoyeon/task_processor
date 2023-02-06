defmodule TaskProcessorWeb.Router do
  use TaskProcessorWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TaskProcessorWeb do
    pipe_through :api

    post "/", TaskController, :index
    post "/bash", TaskController, :bash
  end
end
