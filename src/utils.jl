create_rp(rt::AbstractString) = p -> joinpath(abspath(rt, p))

"""
# generate_ssl

`taken from httpserver example`
"""
function generate_ssl(root_path)
  rp = create_rp(root_path)
  if !isfile("keys/server.crt" |> rp)
    @unix_only begin
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
