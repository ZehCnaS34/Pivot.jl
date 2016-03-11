typealias Verb UInt8
const GET = Verb(1)
const PUT = 2 |> Verb
const POST = 4 |> Verb
const DELETE = 8 |> Verb
const PATCH = 16 |> Verb
verbs = [GET, PUT, POST, DELETE, PATCH]
