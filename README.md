# Pivot

# WARNING NOT DONE!

```julia
using Pivot
using Pivot.Static

app = Engine()

# some middleware
use!(app, Pivot.Logger.simple)
use!(app, Pivot.Static.template("./templates"))

# Handle a request
handle!(GET, app, "/") do ctx
  # The index.html file will is located in the templates directory
  render(ctx, "index.html")
end

# start running the application on port 8080
run(app, 8080)
```
