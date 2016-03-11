using Mux

type Router
    root::Endpoint
    middleware::Function
    port::Int
end

parseurl(str) = filter(split(str, '/')) do str
  str != ""
end

function handle!(fn::Handler,
                 method::Verb,
                 ep::Endpoint)
    ep.handlermap[method] = fn
end

function handle!(fn::Handler, method::Verb, router::Router, path::Vector)
  endpoint = router.root
  if !isempty(path)
    push!(router.root, path)
    endpoint = router.root[path]
  end
  handle!(fn, method, endpoint)
end


handle!(fn::Handler,
        method::Verb,
        router::Router,
        path::AbstractString) = handle!(fn, method, router, parseurl(path))

Router() = Router(StaticEndpoint(), mux(Mux.defaults), 8080)

function baserequest(req, res)
  req = Mux.todict(req)
  res = Mux.response(res)
end

function serve(r::Router)

end
