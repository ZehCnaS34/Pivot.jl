


"""
  Router is the root of the tree
"""
type Router
    root::Endpoint
end

"""
  parseurl should change
"""
parseurl(str) = filter(split(str, '/')) do str
    str != ""
end

"""
  not working
"""
todict(t) = (sym::Symbol) -> (Expr(:., :r, :($sym)))

"""
    todict converts any type passed and returns a dict
    """
function todict(t)
    fields = fieldnames(t)
    output = Dict()
    value = getfield(t)
    for field in fields
        output[field] = value
    end

    output
end

todict(t...) = map(todict, t...)

function handle!(fn::Handler,
                 method::Verb,
                 ep::Endpoint)
    ep.handlermap[method] = fn
end


"""
Mount
takes one routing tree `r2` and attaches it to another routing tree `r1`
the mount will applied according to the specified path `to`

return returns the leaf node
"""
function mount!(r1::Router, r2::Router; to="/")
    root = buildtree(to; root=StaticEndpoint("/"))
    parent = r1[parseurl(to)]
    tokens = parseurl(to)
    push!(r1.root, tokens)
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

Router() = Router(StaticEndpoint())


function fetch(r::Router, tokens::Vector)

end
