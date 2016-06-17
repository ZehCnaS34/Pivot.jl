module Security
using HttpServer, Nettle
import HttpCommon: Cookie

function withcookie(fn::Function, ctx)
    !in(:cookies, ctx.data |> keys) && error("Cookies are not setup properly")
    fn()
end


# COOKIE GETTER AND SETTER -----------------------------------------------------
function setin_cookie!(ctx, key, value)
    withcookie(ctx) do
        ctx.data[:cookies][key] = value
    end
end
function getin_cookie(ctx, key)
    withcookie(ctx) do
        ctx.data[:cookies][key]
    end
end
# ------------------------------------------------------------------------------


# MIDDLEWARE -------------------------------------------------------------------
function session()
    sessionstore = Dict{AbstractString, Dict}()
    function (app, ctx)
        ctx.data[:store] = sessionstore
        ctx.data[:cookies]["PIVOTSESSIONID"] = (!in("PIVOTSESSIONID", keys(ctx.data[:cookies]))) ? "" : ctx.data[:cookies]["PIVOTSESSIONID"]
        ctx.data[:cookies]["PIVOTSESSIONID"] = if in(ctx.data[:cookies]["PIVOTSESSIONID"], sessionstore |> keys)
            Cookie("PIVOTSESSIONID", ctx.data[:cookies]["PIVOTSESSIONID"]).value
        else
            sessionid = hexdigest("sha256", "create-session$(rand(512))")
            sessionstore[sessionid] = Dict{Any, Any}()
            sessionid
        end

        resp = app(ctx)
        ctx.response.cookies["PIVOTSESSIONID"] = Cookie("PIVOTSESSIONID", ctx.data[:cookies]["PIVOTSESSIONID"])
        resp
    end
end
# ------------------------------------------------------------------------------


# STORE GETTER AND SETTER -----------------------------------------------------
function setin_store!(ctx, key, value)
    withcookie(ctx) do
        !in("PIVOTSESSIONID", ctx.data[:cookies] |> keys) && error("The session id was not setup properly")
        sessionid = ctx.data[:cookies]["PIVOTSESSIONID"]
        ctx.data[:store][sessionid][key] = value
    end
end
function getin_store(ctx, key)
    withcookie(ctx) do
        !in("PIVOTSESSIONID", ctx.data[:cookies] |> keys) && error("The session id was not setup properly")
        sessionid = ctx.data[:cookies]["PIVOTSESSIONID"]
        ctx.data[:store][sessionid][key]
    end
end
# -----------------------------------------------------------------------------

function secret(token)
    function (app, ctx)
        ctx.data[:secret] = token
        app(ctx)
    end
end


# Does not work
function csrf(app, ctx)
    if ctx.data[:request][:method] == "POST"
        @show ctx.data[:body]["csrf_token"] == getin_store(ctx, "csrf_token")
        return app(ctx)
    end

    token = hexdigest("sha256", "create-session$(rand(512))")
    println("Storing token $token")
    setin_store!(ctx, "csrf_token", token)
    app(ctx)
end

iscsrfvalid(ctx) = getin_store(ctx, "csrf_token") == ctx.data[:body]["csrf_token"]

end
