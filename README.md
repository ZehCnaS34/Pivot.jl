# Pivot

# WARNING NOT DONE!

```julia
using Pivot

app = Engine()


handle!(GET, app, "/") do ctx
  "Response"
end


run(app, 8080)
```
