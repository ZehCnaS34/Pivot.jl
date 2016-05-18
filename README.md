# Pivot

## TODO List

- [x] Find Julia Html Templating Library (Using Handlebars.jl)
- [ ] Find Julia ORM (Or make one)
- [x] Simple Session Management
- [ ] Cookies
  - [x] Cookie middleware
  - [ ] api to insert cookies into the response
  - [ ] api to parse cookies from response
- [ ]  Security
  - [ ] CSFR
- [ ] Support HTTPS
  - [ ] test remotely
  - [x] setup simple folder structure for ssl keys
- [ ] Create CLI
  - [ ] Create a scaffolding system
- [ ] Build promotional website
- [ ] Support Docker.io natively for deployment


## Examples

### Simple Text Response
```julia
using Pivot

app = Engine()

handle!(app, GET, "/") do ctx
  "This is a simple response"
end

# start running the application on port 8080
run(app, 8080)
```

### Rendering an Html Template

Pivot is uses [Mustache.jl](https://github.com/jverzani/Mustache.jl) for html templating.

```julia
using Pivot
using Pivot.Static

app = Engine()

use!(app, teamplte_directory("./path-to-templates"))

handle!(app, GET, "/") do ctx
  render(ctx, "template-name.html", Dict(
    :key1 => "value",
    :key2 => "value"
  ))
end

# start running the application on port 8080
run(app, 8080)
```
