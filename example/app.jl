using Pivot
import Pivot: Static, Filter, Security, Logger
import Security: setin_store!, getin_store, setin_cookie!, getin_cookie


# Setting up a relative directory for a home path
appdir = @__FILE__() |> abspath |> dirname

app = Engine()

# middleware -------------------------------------------------------------------
use!(app,
     Logger.simple,
     Static.template(appdir),
     Static.public(appdir),
     Static.favicon,
     Filter.cookie_todict,
     Filter.body_todict,
     Filter.query_todict,
     Security.session(),
     Security.secret("ap!@#\$%^&*:""ofij3209f20930239jafa)()(@#\$#@)"),
     Security.csrf)
# custom middleware
use!(app) do app, ctx
    # lets do something to the context
    ctx[:awesome] = "Totally"
    app(ctx)
end
# ------------------------------------------------------------------------------



handle!(app, GET, "/") do ctx
    Static.render(ctx, "index.html",
                  Dict("name"       => "alexander",
                       "csrf_token" => getin_store(ctx, "csrf_token")))
end



# SESSIONS ---------------------------------------------------------------------
handle!(app, GET, "/:name") do ctx
    name = ctx[:params]["name"]
    try
        getin_store(ctx, name)
    catch
        "No key in store with id $name"
    end
end

handle!(app, POST, "/:name") do ctx
    name = ctx[:params]["name"]
    value = ctx[:query]["value"]
    setin_store!(ctx, name, value)
    getin_store(ctx, name)
end
# ------------------------------------------------------------------------------



# COOKIES ----------------------------------------------------------------------
handle!(app, GET, "/cookie/:name") do ctx
    name = ctx[:params]["name"]
    try
        getin_cookie(ctx, name)
    catch
        "No key in store with id $name"
    end
end

handle!(app, POST, "/cookie/:name") do ctx
    name = ctx[:params]["name"]
    value = ctx[:query]["value"]
    setin_cookie!(ctx, name, value)
    getin_cookie(ctx, name)
end
# ------------------------------------------------------------------------------



# FORM -------------------------------------------------------------------------
handle!(app, POST, "/person") do ctx
    Static.render(ctx, "index.html",
                  Dict("name" => "alex"))
end
# ------------------------------------------------------------------------------



handle!(app, GET, "/awesome") do ctx
    ctx[:awesome]
end


Pivot.run(app, 8080)
