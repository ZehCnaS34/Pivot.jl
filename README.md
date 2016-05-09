# WARNING NOT DONE!

# Pivot

## TODO List

- [ ] Find Julia Html Templating Library (Or make one)
- [ ] Find Julia ORM (Or make one)
- [ ] Support HTTPS
- [ ] Create CLI
  - [ ] Create a scaffolding system
- [ ] Build promotional website
- [ ] Support Docker.io natively for deployment
 

## Simple Example

```julia
using Pivot

app = Engine()

handle!(GET, app, "/") do ctx
  "This is a simple response"
end

# start running the application on port 8080
run(app, 8080)
```
