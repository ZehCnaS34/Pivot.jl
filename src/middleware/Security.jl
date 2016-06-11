module Security
using HttpServer, Nettle
import HttpCommon: Cookie

function secret(token)
    function (app, ctx)
        ctx[:secret] = token
        app(ctx)
    end
end

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
    if ctx[:request][:method] == "POST"
        @show ctx[:body]["csrf_token"] == getin_store(ctx, "csrf_token")
        return app(ctx)
    end

    token = hexdigest("sha256", "create-session$(rand(512))")
    println("Storing token $token")
    setin_store!(ctx, "csrf_token", token)
    app(ctx)
end

function withcookie(fn, ctx)
    !in(:cookies, ctx |> keys) && error("Cookies are not setup properly")
    fn()
end


function setin_cookie!(ctx, key, value)
    withcookie(ctx) do
        ctx[:cookies][key] = value
    end
end
function getin_cookie(ctx, key)
    withcookie(ctx) do
        ctx[:cookies][key]
    end
end

function setin_store!(ctx, key, value)
    withcookie(ctx) do
        !in("PIVOTSESSIONID", ctx[:cookies] |> keys) && error("The session id was not setup properly")
        sessionid = ctx[:cookies]["PIVOTSESSIONID"]
        ctx[:store][sessionid][key] = value
    end
end
function getin_store(ctx, key)
    withcookie(ctx) do
        !in("PIVOTSESSIONID", ctx[:cookies] |> keys) && error("The session id was not setup properly")
        sessionid = ctx[:cookies]["PIVOTSESSIONID"]
        ctx[:store][sessionid][key]
    end
end

end
