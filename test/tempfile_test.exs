Code.require_file "test_helper.exs", __DIR__

defmodule TempfileTest do
  use ExUnit.Case

  test "the truth" do
    tf = Tempfile.open
    IO.puts Tempfile.path tf
    assert(Tempfile.open? tf)
    assert(Tempfile.exists? tf)

    tf = Tempfile.close tf
    IO.puts Tempfile.open? tf
    assert(false == Tempfile.open? tf)
    assert(Tempfile.exists? tf)

    tf = Tempfile.unlink tf
    assert(false == Tempfile.open? tf)
    assert(false == Tempfile.exists? tf)
  end
end
