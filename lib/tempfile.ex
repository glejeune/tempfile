defmodule Tempfile do
  defexception IOError, message: "unknown error", can_retry: false do
    def full_message(me) do
      "Tempfile failed: #{me.message}, retriable: #{me.can_retry}"
    end 
  end

  defrecord File, io: nil, path: nil, is_open: false

  defp randstring(size) do
    chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    Enum.reduce 0..size, "", fn(_, acc) -> acc <> String.at(chars, :random.uniform(String.length(chars)) - 1) end
  end

  @doc """
  Get a temporary file name

  Availables options :

  * ext: temp file extension (default: .tmp)
  * path: temp file path (default: System.tmp_dir)

  <b>Examples</b>

      iex> Tempfile.get_name
      "/var/folders/jq/l6wxr88n6wggdqb67bswt7zr0000gn/T/BS6FtL4PDKimRjInCAaID.tmp"

      iex> Tempfile.get_name("prefix_")
      "/var/folders/jq/l6wxr88n6wggdqb67bswt7zr0000gn/T/prefix_LyP23XKsSyXeyLPNeqLa6.tmp"

      iex> Tempfile.get_name("prefix_", [ext: ".my_ext", path: "~/tmp"])
      "~/tmp/prefix_YNzCbL5p751qtVKmfiko5.my_ext"
  """
  def get_name(prefix, options) do
    ext = options[:ext] || ".tmp"
    unless Regex.match?(%r/^\./, ext) do
      ext = "." <> ext
    end
    path = options[:path] || System.tmp_dir
    Path.join(path, prefix <> randstring(20) <> ext)
  end
  def get_name(prefix) when is_bitstring(prefix) do
    get_name(prefix, [])
  end
  def get_name(options) when is_list(options) do
    get_name("tmp", options)
  end
  def get_name do
    get_name("", [])
  end

  @doc """
  Creates a new Tempfile.
  """
  def open do
    open("tmp", [:write])
  end
  def open(ext) when is_bitstring(ext) do
    open(ext, [:write])
  end
  def open(options) when is_list(options) do
    open("tmp", options)
  end
  def open(ext, options) do
    {x, y, z} = :erlang.now
    :random.seed(x, y, z)
    tmp_path = get_name("tmp", [ext: ext])
    case Elixir.File.open(tmp_path, options) do
      {:ok, io} -> Tempfile.File[io: io, path: tmp_path, is_open: true]
      {:error, reason} -> raise Tempfile.IOError, message: reason
    end
  end

  @doc """
  Returns the full path name of the temporary file. This will be nil if unlink has been called.
  """
  def path(tempfile) do
    if nil == tempfile do 
      raise ArgumentError, message: "tempfile must not be nil"
    end
    tempfile.path
  end

  @doc """
  Closes the file.
  """
  def close!(tempfile) do
    close(tempfile, true)
  end
  def close(tempfile) do
    close(tempfile, false)
  end
  def close(tempfile, unlnk) do
    if nil == tempfile do 
      raise ArgumentError, message: "tempfile must not be nil"
    end
    if tempfile.is_open do
      Elixir.File.close(tempfile.io)
      tempfile = tempfile.is_open false
    end
    if unlnk do
      tempfile = unlink(tempfile)
    end
    tempfile
  end

  @doc """
  Unlinks (deletes) the file from the filesystem.
  """
  def unlink(tempfile) do
    if nil == tempfile do 
      raise ArgumentError, message: "tempfile must not be nil"
    end
    close tempfile
    case Elixir.File.rm(tempfile.path) do
      {:error, :enoent} -> raise Tempfile.IOError, message: "The file does not exist"
      {:error, :eacces} -> raise Tempfile.IOError, message: "Missing permission for the file or one of its parents"
      {:error, :eperm} -> raise Tempfile.IOError, message: "The file is a directory and user is not super-user"
      {:error, :enotdir} -> raise Tempfile.IOError, message: "A component of the file name is not a directory"
      {:error, :einval} -> raise Tempfile.IOError, message: "Filename had an improper type"
      :ok -> true
    end
    tempfile = tempfile.path nil
    tempfile = tempfile.io nil
    tempfile = tempfile.is_open false
  end

  @doc """
  Return true if the tempfile is open
  """
  def open?(tempfile) do
    if nil == tempfile do 
      raise ArgumentError, message: "tempfile must not be nil"
    end
    tempfile.is_open
  end

  @doc """
  Return true if the tempfile exists
  """
  def exists?(tempfile) do
    if nil == tempfile do 
      raise ArgumentError, message: "tempfile must not be nil"
    end
    tempfile.path != nil and Elixir.File.exists?(tempfile.path)
  end

  @doc """
  Return the file stat (File.Info)
  """
  def stat(tempfile) do
    if nil == tempfile do 
      raise ArgumentError, message: "tempfile must not be nil"
    end
    case Elixir.File.stat(tempfile.path) do
      {:ok, info} -> info
      {:error, reason} -> raise Tempfile.IOError, message: reason
    end
  end

  @doc """
  Writes the given argument to the given tempfile as a binary, no unicode conversion happens.
  """
  def binwrite(tempfile, item) do
    if nil == tempfile do 
      raise ArgumentError, message: "tempfile must not be nil"
    end
    unless tempfile.is_open do
      raise Tempfile.IOError, message: "File is not open"
    end
    IO.binwrite tempfile.io, item
  end

  @doc """
  Writes the given argument to the given device. By default the device is the standard output. 
  The argument is expected to be a chardata (i.e. a char list or an unicode binary).
  """
  def write(tempfile, item) do
    if nil == tempfile do 
      raise ArgumentError, message: "tempfile must not be nil"
    end
    unless tempfile.is_open do
      raise Tempfile.IOError, message: "File is not open"
    end
    IO.write tempfile.io, item
  end
end
