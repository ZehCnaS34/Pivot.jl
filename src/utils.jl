using Compat
create_rp(rt::AbstractString) = p -> joinpath(abspath(rt, p))

export Utility

"""
# generate_ssl

`taken from httpserver example`
"""
function generate_ssl(root_path)
  rp = create_rp(root_path)
  if !isfile("keys/server.crt" |> rp)
    @compat @unix_only begin
      Base.run(`mkdir -p $(rp("keys"))`)
      Base.run(`openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout
      $(rp("keys/server.key")) -out $(rp("keys/server.crt"))`)
    end
  end
end

"""
# splitquery
"""
function splitquery(req)
  uri = URI(req[:resource])
  delete!(req, :resource)
  req[:path]  = split(uri.path, "/", keep=false)
  req[:query] = uri.query
  req
end

module Utility

"""
# including all files in a folder
"""
macro include_all_in(sym_or_string)
  quote
    for file_name in readdir($(esc(sym_or_string)))
      fn_abspath = joinpath($(esc(sym_or_string)), file_name) |> abspath
      include(fn_abspath)
    end
  end
end

make_appdir(dir) = dir |> dirname |> abspath

end
