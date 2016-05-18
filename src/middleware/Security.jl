module Security
using HttpServer, Nettle
import HttpCommon: Cookie

#  TODO: refactor
"""
# session

Returns a middleware function. The middleware function creates a session store and attaches :store to the context
"""
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

# Does not work
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
