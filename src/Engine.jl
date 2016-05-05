using Mux

function di(req::Request)
  req′ = Dict()
  req′[:method]   = req.method
  req′[:headers]  = req.headers
  req′[:resource] = req.resource
  req.data != "" && (req′[:data] = req.data)
  return req′
end

dim(app, req) = app(di(req))

"""
# Engine
Not sure if this is the proper location of the middleware.

If I put it here, Implementing scope wise middleware will be a little more
difficult.
"""
type Engine
  root
  middleware # TODO: Move to the router.... maybe
end

# Engine() = Engine(Pivot.Router(), stack(dim, Mux.splitquery))
Engine() = Engine(Pivot.Router(), stack(Mux.defaults))

handle!(fn::Handler,
        method::Verb,
        e::Engine,
        path::AbstractString) = handle!(fn, method, e.root, parseurl(path))

use!(e::Engine, fn::Function) = use!(e.root, fn)
use!(fn::Function, e::Engine) = use!(e.root, fn)

# convenience.
rmux(app, mw) = mux(mw, app)

function run(e::Engine, port::Number=8080)
  http = HttpHandler() do req::Request, res::Response
    req |> rmux(e.middleware) do rq
      # need to figure out a way to have scoped middleware
      endpoint = fetch(e.root, rq[:path])
      e.root.mw(endpoint.handlermap[STI[rq[:method]]], Dict(
        :request => rq,
        :endpoint => endpoint
      ))
    end
  end

  server = Server(http)
  HttpServer.run(server, port)

end
