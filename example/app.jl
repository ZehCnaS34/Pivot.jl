using Pivot
using Pivot.Static

# Setting up a relative directory for a home path
appdir = @__FILE__() |> abspath |> dirname


app = Engine()

use!(app, Pivot.Logger.simple)
use!(app, Pivot.Static.template(appdir))
eng!(app, Pivot.Static.public(appdir))

handle!(GET, app, "/") do ctx
  render(ctx, "index.html")
end

handle!(GET, app, "/:name") do ctx
  endpoint = ctx[:endpoint]
  render(ctx, "namer.html")
end

Pivot.run(app, 8080)
