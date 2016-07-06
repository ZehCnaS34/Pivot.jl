module Security
using HttpServer, Nettle
import HttpCommon: Cookie

function withcookie(fn::Function, ctx)
    !in(:cookies, ctx.data |> keys) && error("Cookies are not setup properly")
    fn()
end


# COOKIE GETTER AND SETTER -----------------------------------------------------
function setin_cookie!(ctx, key, value)
    # adding new cookies added from the handler to the response
    ctx.data[:cookies][key] = value
    ctx.response.cookies[string(key)] = Cookie(string(key), value)
end
function getin_cookie(ctx, key)
    ctx.data[:cookies][key]
end
# ------------------------------------------------------------------------------


function get_sessionid(ctx)
    if ("PIVOTSESSIONID" in  keys(ctx.data[:cookies]))
        ctx.data[:cookies]["PIVOTSESSIONID"]
    else
        ""
    end
end


"""
looks into the context and checks if there is an alread existing session id.
If there is one, leave it as so.
If there is not one, generate a new session id key

PRECONDITIONS:
    - the cookie middleware must be in place
    - PIVOTSESSIONID must be in the cookies
"""
function gen_sessionid(fn, ctx)
    if fn(getin_cookie(ctx, "PIVOTSESSIONID"))
        getin_cookie(ctx, "PIVOTSESSIONID")
    else
        sessionid = hexdigest("sha256", "create-session$(rand(512))")
        sessionid
    end
end

# just a little dict helper
function setifnothing(dict, key, value)
    if key in keys(dict)
        dict[key]
    else
        dict[key] = value
    end
end


# MIDDLEWARE -------------------------------------------------------------------
"""
# session

creates a closure, that acts as a session store.
"""
function session()
    sessionstore = Dict{AbstractString, Dict}()
    function (app, ctx)
        setin_cookie!(ctx, "PIVOTSESSIONID", get_sessionid(ctx))

        sessionid = gen_sessionid(ctx) do id
            id in keys(sessionstore)
        end

        setifnothing(sessionstore, sessionid, Dict{Any, Any}())

        ctx.data[:session] = sessionstore[sessionid]
        setin_cookie!(ctx, "PIVOTSESSIONID", sessionid)
        app(ctx)
    end
end
# ------------------------------------------------------------------------------


# STORE GETTER AND SETTER -----------------------------------------------------
function setin_session!(ctx, key, value)
    ctx.data[:session][key] = value
end
function getin_session(ctx, key)
    ctx.data[:session][key]
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
        @show ctx.data[:body]["csrf_token"] == getin_session(ctx, "csrf_token")
        return app(ctx)
    end

    token = hexdigest("sha256", "create-session$(rand(512))")
    println("Storing token $token")
    setin_session!(ctx, "csrf_token", token)
    app(ctx)
end

iscsrfvalid(ctx) = getin_session(ctx, "csrf_token") == ctx.data[:body]["csrf_token"]

end
