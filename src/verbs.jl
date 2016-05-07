typealias Verb UInt8

const GET    = 1  |> Verb
const PUT    = 2  |> Verb
const POST   = 4  |> Verb
const DELETE = 8  |> Verb
const PATCH  = 16 |> Verb

const STI = Dict(
  "GET"    =>  GET,
  "PUT"    =>  PUT,
  "POST"   =>  POST,
  "DELETE" =>  DELETE,
  "PATCH"  =>  PATCH
)

"""
for cases when an endpoint can many different verbs
"""
function proper_method(verb, map)
  in(verb, map |> keys) && return map[verb]


  for v in keys(map)
    verb & v > 0 && return map[v]
  end

  return nothing
end
