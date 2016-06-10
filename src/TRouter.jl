import Base.fetch

export TRouter

"""
TRouter is the root of the tree
"""
type TRouter <: Router
    root::Endpoint
    middleware::Function
    TRouter() = new(StaticEndpoint(), Mux.basiccatch)
end

"""
# parseurl

should change
This does not support params
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
function mount!(r1::TRouter, r2::TRouter; to="/")
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
                 ep::Endpoint,
                 method::Verb)
    ep.handlermap[method] = fn
end

function handle!(fn::Handler,
                 router::TRouter,
                 method::Verb,
                 path::Vector)
    endpoint = router.root
    if !isempty(path)
        endpoint = push!(endpoint, path)
    end
    handle!(fn, endpoint, method)
end

function use!(router::TRouter, fn::Function)
    router.middleware = stack(router.middleware, fn)
end

fetch(r::TRouter, tokens::Vector) = r.root[deepcopy(tokens), Dict()]

"""
# finalize!

just calls the finalize method that is provided by endpoint
"""
finalize!(r::TRouter) = finalize!(router.root)

# TRouter specific helper functions
