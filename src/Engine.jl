"""
# Engine
Not sure if this is the proper location of the middleware.

If I put it here, Implementing scope wise middleware will be a little more
difficult.
"""
type Engine
  router
  middleware
end

# right now, I'll just use the default Mux
Engine() = Engine(Pivot.Router(), stack(Mux.defaults))

handle!(fn::Handler,
        method::Verb,
        e::Engine,
        path::AbstractString) = handle!(fn, method, e.router, parseurl(path))

use!(e::Engine, fn::Function) = use!(e.router, fn)
use!(fn::Function, e::Engine) = use!(e.router, fn)

# convenience.
rmux(app, mw) = mux(mw, app)

"""
# finalize!

just calls the finalize method that is provided by endpoint
"""
finalize!(e::Engine) = finalize!(e.router.root)

function run(e::Engine, port::Number=8080)
  Pivot.finalize!(e)
  http = HttpHandler() do req::Request, res::Response
    req |> rmux(e.middleware) do rq
      endpoint = fetch(e.router, rq[:path])
      verb = STI[rq[:method]]

      e.router.middleware(proper_method(verb, endpoint.handlermap), Dict(
        :request => rq,
        :endpoint => endpoint
      ))
    end
  end

  server = Server(http)
  HttpServer.run(server, port)

end
