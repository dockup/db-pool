defmodule DbPoolWeb.Router do
  use DbPoolWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DbPoolWeb do
    pipe_through :browser # Use the default browser stack

    get "/", DatabaseController, :index
    post "/databases/bulk", DatabaseController, :bulk, as: :database_bulk
    resources "/databases", DatabaseController do
      put "/import", DatabaseController, :import_dump, as: :import
    end
  end

  scope "/api", as: :api, alias: DbPoolWeb.API do
    pipe_through :api

    post "/create", DatabaseController, :create
    post "/delete/:id", DatabaseController, :delete
    get "/items", DatabaseController, :items
  end
end
