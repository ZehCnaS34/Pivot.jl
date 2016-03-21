module Pivot
using Mux
using HttpServer

export Endpoint,
StaticEndpoint,
DynamicEndpoint,
Router,
handle!,
match,
GET,
PUT,
POST,
DELETE,
PATCH



# package code goes here
include("verbs.jl")
include("Endpoint.jl")
include("Router.jl")


end # module
