module Security
using HttpServer, Nettle
import HttpCommon: Cookie

#  TODO: refactor
function session()
  sessionstore = Dict{Any, Dict}()
  function (app, ctx)
    ctx[:store] = sessionstore
    ctx[:cookies]["PIVOTSESSIONID"] = (!in("PIVOTSESSIONID", keys(ctx[:cookies]))) ? "" : ctx[:cookies]["PIVOTSESSIONID"]
    ctx[:cookies]["PIVOTSESSIONID"] = if in(ctx[:cookies]["PIVOTSESSIONID"], sessionstore |> keys)
      Cookie("PIVOTSESSIONID", ctx[:cookies]["PIVOTSESSIONID"]).value
    else
      # ehhhh lol
      sessionid = hexdigest("sha256", "create-session$(rand(512))")
      sessionstore[sessionid] = Dict{Any, Any}()
      sessionid
    end

    resp = app(ctx)
    resp = Response(resp)
    resp.cookies["PIVOTSESSIONID"] = Cookie("PIVOTSESSIONID", ctx[:cookies]["PIVOTSESSIONID"])
    resp
  end
end

function csrf(app, ctx)
  token = hexdigest("sha256", "create-session$(rand(512))")
  setstore!(ctx, "csrf_token", token)
  app(ctx)
end


function setin_store!(ctx, key, value) 
  !in(:cookies, ctx |> keys) && error("Cookies are not setup properly")
  !in("PIVOTSESSIONID", ctx[:cookies] |> keys) && error("The session id was not setup properly")
  sessionid = ctx[:cookies]["PIVOTSESSIONID"]
  ctx[:store][sessionid][key] = value
end

function getin_store(ctx, key)
  !in(:cookies, ctx |> keys) && error("Cookies are not setup properly")
  !in("PIVOTSESSIONID", ctx[:cookies] |> keys) && error("The session id was not setup properly")
  sessionid = ctx[:cookies]["PIVOTSESSIONID"]
  ctx[:store][sessionid][key]
end

end


# TODO: make this module dry
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


module Logger
import HttpServer.mimetypes

"""
# simple
assumes that the proper engine middleware is included
"""
function simple(ap, ctx)
  s = time()
  output =  ap(ctx)
  f = time()
  println("[$(ctx[:request][:method]) $(join(ctx[:request][:path], "/") * "/")] -- $(f - s) (s)")
  output
end

end

module Static

using Mustache
export render
import HttpServer: Response, mimetypes

"""
Defines the proper variables for the template home
"""
function template(template_directory)
  function (app, ctx)
    ctx[:template_dir] = abspath(template_directory)
    app(ctx)
  end
end


function mime(s)
  if in(s, mimetypes |> keys)
    return mimetypes[s]
  end
  "text/plain"
end




"""
# public serve some static files?
"""
function public(public_directory)
  function (app, ctx)
    resourcefile = joinpath(public_directory,
      join(ctx[:request][:path], "/")) |> abspath

    if isfile(resourcefile)
      ext = split(resourcefile |> basename, ".")[end]
      f = open(resourcefile)
      res = Response(join(readlines(f), ""))
      close(f)
      res.headers["Content-Type"] = mime(ext) * "; charset=utf-8"
      return res
    end

    app(ctx)
  end
end

"""
# render

should render a file as a request

later on, I should deff cache this
"""
function render(ctx, filename, data=Dict())
  template_location = ctx[:template_dir]
  f = open(joinpath(template_location, filename))
  content = join(readlines(f), "")
  close(f)
  Mustache.render(content, data)
end

end
