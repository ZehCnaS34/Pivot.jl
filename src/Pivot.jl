module Pivot
__precompile__()
using Mux
using HttpServer

export Endpoint,
  StaticEndpoint,
  DynamicEndpoint,
  Router,
  Engine,
  handle!,
  match,
  run,
  GET,
  PUT,
  POST,
  DELETE,
  PATCH

# package code goes here
include("verbs.jl")
include("Endpoint.jl")
include("Router.jl")
include("Engine.jl")

end # module
