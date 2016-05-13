using Pivot
using Pivot.Static

# Setting up a relative directory for a home path
appdir = @__FILE__() |> abspath |> dirname

app = Engine()

# middleware
use!(app, Pivot.Logger.simple)
use!(app, Pivot.Static.template(appdir))
use!(app, Pivot.Static.public(appdir))

handle!(app, GET, "/") do ctx
  render(ctx, "index.html")
end

handle!(app, GET, "/game") do ctx
  render(ctx, "jsbin.barixo.15.html")
end

handle!(app, GET, "/:name") do ctx
  endpoint = ctx[:endpoint]
  render(ctx, "namer.html", Dict(
    "name" => endpoint.captured
  ))
end

Pivot.run(app, 8080)
