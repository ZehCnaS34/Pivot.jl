using URIParser, MbedTLS

"""
# Engine
Not sure if this is the proper location of the middleware.

If I put it here, Implementing scope wise middleware will be a little more
difficult.
"""
type Engine
  router
end

# right now, I'll just use the default Mux
Engine() = Engine(Pivot.Router())

handle!(
  fn::Handler,
  e::Engine,
  method::Verb,
  path::AbstractString
) = handle!(fn, e.router, method, parseurl(path))

handle!(
  e::Engine,
  fn::Handler,
  method::Verb,
  path::AbstractString
) = handle!(fn, e.router, method, parseurl(path))

use!(e::Engine, fn::Function) = use!(e.router, fn)
use!(fn::Function, e::Engine) = use!(e.router, fn)

"""
# finalize!

just calls the finalize method that is provided by endpoint
"""
finalize!(e::Engine) = finalize!(e.router.root)

function buildhandler(router::Router)
  function (ctx)
    ep = fetch(router, ctx[:request][:path])
    method = STI[ctx[:request][:method]]
    ctx[:endpoint] = ep
    ctx |> proper_method(method, ep.handlermap)
  end
end

"""
# run

runs the server
"""
function run(e::Engine, port::Number=8080; keyspath="")
  Pivot.finalize!(e)
  http = HttpHandler() do req::Request, res::Response
    # need to parse the path
    rq = req |> Mux.todict |> Pivot.splitquery

    mux(e.router.middleware, buildhandler(e.router))(
      Dict{Symbol, Any}(:request => rq))
  end

  server = Server(http)

  # ssl for https
  # TODO: test remotely
  if keyspath != ""
    rel = create_rp(keyspath)
    generate_ssl(rel(""))

    cert = MbedTLS.crt_parse_file(rel("keys/server.crt"))
    key = MbedTLS.parse_keyfile(rel("keys/server.key"))
    HttpServer.run(server, port=port, ssl=(cert, key))
    return
  end

  HttpServer.run(server, port)
end
