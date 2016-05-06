using Pivot

app = Engine()

use!(app, Pivot.Logger.simple)

handle!(GET, app, "/") do ctx # might change this to context
  "This should not make anything precompile if it is modified."
end

handle!(GET, app, "/:name") do ctx
  "Name will be here $(ctx[:endpoint].captured) eventually"
end

handle!(GET, app, "/timed") do ctx
  sleep(4)
  "This should take some time."
end

Pivot.run(app, 8080)
