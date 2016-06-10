"""
Filter contains middleware that is able to mutate the request map.
These functions are most commonly used to make accessing data from the request more simple and straight forward.
"""
module Filter

using HttpServer
import HttpCommon: Cookie

"""
# strtodict

converts
"""
function strtodict(str, delim)
  str = split(str, delim)
  str = map((kv) -> split(kv, "="), str)
  str = filter((l) -> length(l) > 1, str)
  [ k => v for (k, v) in str ]
end

"""
# body_todict(app, ctx)

Converts the query from the request to a dictionary. Then stores in to locations
```julia
ctx[:request][:data] ## overwriting the raw version
ctx[:body] ## for convenience
```
"""
function body_todict(app, ctx)
  if !in(:data, ctx[:request] |> keys)
    ctx[:data] = Dict()
    return app(ctx)
  end
  raw_data = convert(ASCIIString, ctx[:request][:data])
  data = strtodict(raw_data, "&")
  ctx[:body] = data
  app(ctx)
end


"""
# body_todict(app, ctx)

Converts the query from the request to a dictionary. Then stores in to locations
```julia
ctx[:request][:cookie] ## overwriting the raw version
ctx[:cookie] ## for convenience
```
"""
function cookie_todict(app, ctx)
  if !in("Cookie", keys(ctx[:request][:headers]))
    ctx[:cookies] = Dict()
    resp = app(ctx)
    return resp
  end
  dough = ctx[:request][:headers]["Cookie"]
  cookie = strtodict(dough, "; ")
  ctx[:cookies] = cookie
  resp = app(ctx)

  # adding new cookies added from the handler to the response
  for (k, v) in ctx[:cookies]
    resp.cookies[string(k)] = Cookie(k, v)
  end
  return resp
end

"""
# query_todict

Converts the query from the request to a dictionary. Then stores in to locations
```julia
ctx[:request][:query] ## overwriting the raw version
ctx[:query] ## for convenience
```
"""
function query_todict(app, ctx)
  raw_query = ctx[:request][:query]
  marshalled = strtodict(raw_query, "&")
  ctx[:request][:query] = marshalled
  ctx[:query]           = marshalled
  app(ctx)
end

end
