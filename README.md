# WARNING NOT DONE!

# Pivot


## TODO List

- [ ] Find Julia Html Templating Library (Or make one)
- [ ] Find Julia ORM (Or make one)
- [ ] Support HTTPS
- [ ] Create CLI
  - [ ] Create a scaffolding system
- [ ] Build promotional website
 

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
