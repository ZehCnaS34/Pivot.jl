module Filter
using HttpServer
import HttpCommon: Cookie

function body_todict(app, ctx)
  !in(:data, ctx[:request] |> keys) && begin
    ctx[:data] = Dict()
    return app(ctx)
  end
  raw_data = convert(ASCIIString, ctx[:request][:data])
  raw_data = split(raw_data, "&")
  raw_data = map((kv) -> split(kv, "="), raw_data)
  raw_data = filter((l) -> length(l) > 1, raw_data)
  data = [ k => v for (k, v) in raw_data ] |> Dict
  ctx[:body] = data
  app(ctx)
end

function cookie_todict(app, ctx)
  !in("Cookie", ctx[:request][:headers] |> keys) && begin
    ctx[:cookies] = Dict()
    return app(ctx)
  end
  dough = ctx[:request][:headers]["Cookie"]

  dough = split(dough, "; ")
  dough = map((kv) -> split(kv, "="), dough)
  dough = filter((l) -> length(l) > 1, dough)
  cookie = [ k => v for (k, v) in dough ] |> Dict
  ctx[:cookies] = cookie
  app(ctx)
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
    tda = filter(map((kv) -> split(kv, "="), split(raw_query, "&"))) do p
      length(p) > 1
    end
    marshalled = [ key_type(k) => v for (k,v) in tda]
    ctx[:request][:query] = marshalled
    ctx[:query] = marshalled
    app(ctx)
  end
end

end
