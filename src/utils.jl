function splitquery(req)
  uri = URI(req[:resource])
  delete!(req, :resource)
  req[:path]  = split(uri.path, "/", keep=false)
  req[:query] = uri.query
  req
end
