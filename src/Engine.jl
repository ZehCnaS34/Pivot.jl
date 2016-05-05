using Mux

type Engine
  root
end

Engine() = Engine(Pivot.Router())


handle!(fn::Handler,
        method::Verb,
        e::Engine,
        path::AbstractString) = handle!(fn, method, e.root, parseurl(path))


function run(e::Engine, port::Number=8080)
  http = HttpHandler() do req::Request, res::Response
    rq = todict(req)
    rs = todict(res)
    println(rq[:method])
    println(rq[:resource])

    tokens = parseurl(rq[:resource])
    endpoint = fetch(e.root, tokens)
    endpoint.handlermap[STI[rq[:method]]](rq,rs)
  end

  server = Server(http)
  HttpServer.run(server, port)

end
