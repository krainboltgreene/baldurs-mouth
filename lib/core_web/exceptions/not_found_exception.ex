defmodule CoreWeb.Exceptions.NotFoundException do
  defexception message: "Resource Not Found", plug_status: 404
end
