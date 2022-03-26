defmodule KOATUU do
  require Record

  Enum.each(Record.extract_all(from_lib: "koatuu/include/dict.hrl"), fn {name, definition} ->
    Record.defrecord(name, definition)
  end)

end

