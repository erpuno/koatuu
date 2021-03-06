defmodule KOATUU do
  require Record

  Enum.each(
    Record.extract_all(from_lib: "koatuu/include/koatuu.hrl"),
    fn {name, definition} -> Record.defrecord(name, definition) end
  )

end
