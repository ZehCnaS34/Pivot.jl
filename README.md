# Pivot

# WARNING NOT DONE!

```julia
using Pivot
using Pivot.Static

app = Engine()

# some middleware
eng!(app, Pivot.Static.public("./public"))
use!(app, Pivot.Static.template("./views"))

# Handle a request
handle!(GET, app, "/") do ctx
  render(ctx, "index.html")
end

# start running the application on port 8080
run(app, 8080)
```
