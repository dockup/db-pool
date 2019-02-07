alias DbPool.Repo
alias DbPool.Core
alias DbPool.Core.{
  Pool,
  Database,
  Scheduler,
  Importer,
  Deleter,
  BulkCreator
}
import DbPool.Utils
import Ecto.Query, warn: false
defmodule Utils do
  def delete_all(), do: Repo.all(Database) |> Enum.each(&(Deleter.run(&1)))
  def import(), do: BulkCreator.run()
end
