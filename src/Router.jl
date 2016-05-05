"""
  Router is the root of the tree
"""
type Router
    root::Endpoint
end

"""
  parseurl should change
"""
parseurl(str) = filter((s) -> s != "", split(str, '/'))

"""
A helper macro I made to make it easier to convert Request and Response
types to dictionaries
"""
macro field(typ, attr)
    typeof(typ) != Symbol && error("First argument must be a symbol")
    if typeof(attr) == Symbol
        Expr(:., (esc(typ)), :($attr))
    else
        Expr(:., (esc(typ)), :($(esc(attr))))
    end
end

"""
    todict converts any type passed and returns a dict
"""
function todict(typ)
    output = Dict()
    for field in fieldnames(typ)
        output[field] = @field typ field
    end
    output
end

todict(t...) = map(todict, t)

"""
# Mount
takes one routing tree `r2` and attaches it to another routing tree `r1`
the mount will applied according to the specified path `to`

return returns the leaf node
"""
function mount!(r1::Router, r2::Router; to="/")
    root = buildtree(to; root=StaticEndpoint("/"))
    tokens = parseurl(to)
    parent = r1[tokens]
    push!(r1.root, tokens)
end


"""
# handle!

attaches the handler::Function to the handlemap contained on the leaf endpoint
of the path.
"""
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

function handle(fn::Handler, method::Verb, path::AbstractString)
    function (r::Router)
        handle!(fn, method, r, path)
    end
end

Router() = Router(StaticEndpoint())

function fetch(r::Router, tokens::Vector)
    r.root[tokens]
end
