typealias Verb UInt8

const GET    = 1  |> Verb
const PUT    = 2  |> Verb
const POST   = 4  |> Verb
const DELETE = 8  |> Verb
const PATCH  = 16 |> Verb

verbs = [GET, PUT, POST, DELETE, PATCH]

const STI = Dict(
  "GET"    =>  GET,
  "PUT"    =>  PUT,
  "POST"   =>  POST,
  "DELETE" =>  DELETE,
  "PATCH"  =>  PATCH
)
