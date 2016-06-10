using Pivot
import Pivot: Static, Filter, Security
import Security: setin_store!, getin_store

# Setting up a relative directory for a home path
appdir = @__FILE__() |> abspath |> dirname

app = Engine()

# middleware
use!(app, Pivot.Logger.simple)
use!(app, Pivot.Static.template(appdir))
use!(app, Pivot.Static.public(appdir))
use!(app, Filter.cookie_todict)
use!(app, Filter.body_todict)
use!(app, Filter.query_todict)
use!(app, Security.session())


# customer middleware
use!(app) do app, ctx
  # lets do something to the context
  app(ctx)
end

handle!(app, GET, "/") do ctx
  Static.render(ctx, "index.html")
end

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

Pivot.run(app, 8080)
