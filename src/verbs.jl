typealias Verb UInt8

const GET    = 1 << 0 |> Verb
const PUT    = 1 << 1 |> Verb
const POST   = 1 << 2 |> Verb
const DELETE = 1 << 3 |> Verb
const PATCH  = 1 << 4 |> Verb

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
