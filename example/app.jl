using Pivot
using Pivot.Static

# Setting up a relative directory for a home path
appdir = @__FILE__() |> abspath |> dirname

app = Engine()

# middleware
use!(app, Pivot.Logger.simple)
use!(app, Pivot.Static.template(appdir))

handle!(GET, app, "/") do ctx
  render(ctx, "index.html")
end

handle!(GET, app, "/game") do ctx
  render(ctx, "jsbin.barixo.15.html")
end

handle!(GET, app, "/:name") do ctx
  endpoint = ctx[:endpoint]
  render(ctx, "namer.html")
end

Pivot.run(app, 8080)
