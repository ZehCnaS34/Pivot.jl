import Base.fetch

export Routing

"""
Router is the root of the tree
"""
type Router
  root::Endpoint
  middleware::Function
end

"""
# parseurl

should change
This does not support params
"""
parseurl(str) = filter((s) -> s != "", split(str, '/'))

"""
A helper macro I made to make it easier to convert Request and Response
types to dictionaries
"""
macro field(typ, attr)
  typeof(typ) != Symbol && error("First argument must be a symbol")
  if typeof(attr) == Symbol
    Expr(:., (esc(typ)), :($attr))
  else
    Expr(:., (esc(typ)), :($(esc(attr))))
  end
end

"""
todict converts any type passed and returns a dict
"""
function todict(typ)
  output = Dict()
  for field in fieldnames(typ)
    output[field] = @field typ field
  end
  output
end

todict(t...) = map(todict, t)

"""
# Mount
takes one routing tree `r2` and attaches it to another routing tree `r1`
the mount will applied according to the specified path `to`

return returns the leaf node
"""
function mount!(r1::Router, r2::Router; to="/")
  root = buildtree(to; root=StaticEndpoint("/"))
  tokens = parseurl(to)
  parent = r1[tokens]
  push!(r1.root, tokens)
end


"""
# handle!

attaches the handler::Function to the handlemap contained on the leaf endpoint
of the path.
"""
function handle!(
  fn::Handler,
  ep::Endpoint,
  method::Verb
)
  ep.handlermap[method] = fn
end

function handle!(
  fn::Handler, 
  router::Router, 
  method::Verb, 
  path::Vector
)
  endpoint = router.root
  if !isempty(path)
    endpoint = push!(endpoint, path)
  end
  handle!(fn, endpoint, method)
end

handle!(
  fn::Handler,
  router::Router,
  method::Verb,
  path::AbstractString
) = handle!(fn, router, method, parseurl(path))

handle!(
  router::Router,
  fn::Handler,
  method::Verb,
  path::AbstractString
) = handle!(fn, router, method, parseurl(path))

function use!(router::Router, fn::Function)
  router.middleware = stack(router.middleware, fn)
end

use!(fn::Function, r::Router) = use!(r, fn)

Router() = Router(StaticEndpoint(), Mux.basiccatch)

function fetch(r::Router, tokens::Vector)
  toks = deepcopy(tokens)
  r.root[toks]
end


module Routing
using Pivot

"""
# make_partial_route

build a 
"""
function make_partial_route(method, path, handler)
  :(handle!($(handler), $(method), $(path)))
end

"""
# get

"/" => HomeController.index
"""
macro get(phandler)
  :(make_partial_route(GET, $(phandler.args[1]), $(esc(phandler.args[2]))))
end

macro post(phandler)
  :(make_partial_route(POST, $(phandler.args[1]), $(esc(phandler.args[2]))))
end

macro put(phandler)
  :(make_partial_route(PUT, $(phandler.args[1]), $(esc(phandler.args[2]))))
end

macro delete(phandler)
  :(make_partial_route(DELETE, $(phandler.args[1]), $(esc(phandler.args[2]))))
end

end

