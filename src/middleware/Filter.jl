module Filter
using HttpServer
import HttpCommon: Cookie

function strtodict(str, delim)
  str = split(str, delim)
  str = map((kv) -> split(kv, "="), str)
  str = filter((l) -> length(l) > 1, str)
  [ k => v for (k, v) in str ]
end

function body_todict(app, ctx)
  !in(:data, ctx[:request] |> keys) && begin
    ctx[:data] = Dict()
    return app(ctx)
  end
  raw_data = convert(ASCIIString, ctx[:request][:data])
  data = strtodict(raw_data, "&")
  ctx[:body] = data
  app(ctx)
end


function cookie_todict(app, ctx)
  !in("Cookie", ctx[:request][:headers] |> keys) && begin
    ctx[:cookies] = Dict()
    resp = app(ctx)
    return resp
  end
  dough = ctx[:request][:headers]["Cookie"]
  cookie = strtodict(dough, "; ")
  ctx[:cookies] = cookie
  resp = app(ctx)
  for (k, v) in ctx[:cookies]
    resp.cookies[string(k)] = Cookie(k, v)
  end
  return resp
end

"""
# query_todict

Converts the query from the request to a dictionary. Then stores in to locations
ctx[:request][:query] -- overwriting the raw version
ctx[:query] -- for convenience
"""
function query_todict(key_type=string)
  function (app, ctx)
    raw_query = ctx[:request][:query]
    marshalled = strtodict(raw_query, "&")
    ctx[:request][:query] = marshalled
    ctx[:query] = marshalled
    app(ctx)
  end
end

end
