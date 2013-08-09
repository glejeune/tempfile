Code.require_file "test_helper.exs", __DIR__

defmodule TempfileTest do
  use ExUnit.Case

  test "the basics" do
    tf = Tempfile.open
    if nil == tf do
      IO.puts "NULL !!!!"
    end
    assert(Tempfile.open? tf)
    assert(Tempfile.exists? tf)

    tf = Tempfile.close tf
    assert(false == Tempfile.open? tf)
    assert(Tempfile.exists? tf)

    tf = Tempfile.unlink tf
    assert(false == Tempfile.open? tf)
    assert(false == Tempfile.exists? tf)
  end

  test "multi files" do
    tf1 = Tempfile.open
    tf2 = Tempfile.open
    assert(Tempfile.path(tf1) != Tempfile.path(tf2))

    tf1 = Tempfile.close! tf1
    assert(false == Tempfile.exists? tf1)

    tf2 = Tempfile.close! tf2
    assert(false == Tempfile.exists? tf2)
  end

  test "Write to file" do
    tf = Tempfile.open
    assert(Tempfile.open? tf)

    Tempfile.write tf, "Hello World"
    assert(11 == Tempfile.stat(tf).size)
    
    tf = Tempfile.close! tf
    assert(false == Tempfile.exists? tf)
  end

  test "raise" do
    assert_raise ArgumentError, fn ->
      Tempfile.stat nil
    end
    assert_raise ArgumentError, fn ->
      Tempfile.path nil
    end
    assert_raise ArgumentError, fn ->
      Tempfile.close nil
    end
    assert_raise ArgumentError, fn ->
      Tempfile.unlink nil
    end
    assert_raise ArgumentError, fn ->
      Tempfile.open? nil
    end
  end
end
