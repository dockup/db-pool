defmodule DbPoolWeb.DatabaseView do
  use DbPoolWeb, :view

  def fa_icon_color_for(database) do
    case database.status do
      "created" -> "has-text-grey-lighter"
      "importing" -> "has-text-info"
      "imported" -> "has-text-success"
      "deleting" -> "has-text-danger"
      "deleted" -> "has-text-grey-lighter"
    end
  end

  def fa_icon_for(database) do
    case database.status do
      "created" -> "fa-circle"
      "importing" -> "fa-file-import"
      "imported" -> "fa-check-circle"
      "deleting" -> "fa-trash"
      "deleted" -> "fa-trash"
    end
  end
end
