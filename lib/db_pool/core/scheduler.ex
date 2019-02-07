# https://github.com/code-mancers/dockup/blob/eadc53a8/apps/dockup_ui/lib/dockup_ui/scheduler.ex
# Copied from DockupUi.Scheduler to keep it simple :)
defmodule DbPool.Core.Scheduler do
  use GenServer
  require Logger

  import Ecto.Query, warn: false

  alias DbPool.Core.{
    Database,
    BulkCreator,
    Importer,
    Deleter
  }

  @interval_5_mins_msec 30 * 1000 # 5 * 60 * 1000

  @doc """
  Starts a Scheduler and kicks off the loop
  """
  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    Process.send(self(), :replenish_if_required, [])
    Process.send(self(), :import_if_any, [])
    Process.send(self(), :delete_if_any, [])
    {:ok, nil}
  end

  def handle_info(:replenish_if_required, state) do
    replenish_databases_if_required()

    {:noreply, state}
  end

  def handle_info(:import_if_any, state) do
    import_databases_if_any()

    {:noreply, state}
  end

  def handle_info(:delete_if_any, state) do
    delete_databases_if_any()

    {:noreply, state}
  end

  defp set_update_timer(event) do
    Process.send_after(self(), event, @interval_5_mins_msec)
  end

  defp replenish_databases_if_required do
    databases_imported_or_importing =
      Database
      |> Ecto.Query.where([d], d.status in ["importing", "imported"])
      |> DbPool.Repo.aggregate(:count, :id)

    if databases_imported_or_importing < 10 do
      BulkCreator.run()
    end

    set_update_timer(:replenish_if_required)
  end

  defp import_databases_if_any do
    next_database_to_import =
      Database
      |> Ecto.Query.where(status: "importing")
      |> Ecto.Query.order_by([asc: :id])
      |> Ecto.Query.first
      |> DbPool.Repo.one

    if next_database_to_import do
      case Importer.start_importing(next_database_to_import) do
        :ok ->
          Process.send(self(), :import_if_any, [])

        :error ->
          set_update_timer(:import_if_any)
      end
    else
      set_update_timer(:import_if_any)
    end
  end

  defp delete_databases_if_any do
    next_database_to_delete =
      Database
      |> Ecto.Query.where(status: "deleting")
      |> Ecto.Query.order_by([asc: :id])
      |> Ecto.Query.first
      |> DbPool.Repo.one

    if next_database_to_delete do
      case Deleter.start_deleting(next_database_to_delete) do
        :ok ->
          Process.send(self(), :delete_if_any, [])

        :error ->
          set_update_timer(:delete_if_any)
      end
    else
      set_update_timer(:delete_if_any)
    end
  end
end
