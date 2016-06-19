import Base.fetch

export TRouter

mux_css = """
  body { font-family: sans-serif; padding:50px; }
  .box { background: #fcfcff; padding:20px; border: 1px solid #ddd; border-radius:5px; }
  pre { line-height:1.5 }
  a { text-decoration:none; color:#225; }
  a:hover { color:#336; }
  u { cursor: pointer }
  """

error_phrases = ["Looks like someone needs to pay their developers more."
                 "Someone order a thousand more monkeys! And a million more typewriters!"
                 "Maybe it's time for some sleep?"
                 "Don't bother debugging this one – it's almost definitely a quantum thingy."
                 "It probably won't happen again though, right?"
                 "F5! F5! F5!"
                 "F5! F5! FFS!"
                 "On the bright side, nothing has exploded. Yet."
                 "If this error has frustrated you, try clicking <u>here</u>."]

"""
# basiccatch

support Pivot middleware.
"""
function basiccatch(app, ctx)
    try
        app(ctx)
    catch e
        io = IOBuffer()
        println(io, "<style>", mux_css, "</style>")
        println(io, "<h1>Internal Error</h1>")
        println(io, "<p>$(error_phrases[rand(1:length(error_phrases))])</p>")
        println(io, "<pre class=\"box\">")
        showerror(io, e, catch_backtrace())
        println(io, "</pre>")
        ctx.response.status = 500
        return takebuf_string(io)
    end
end

"""
TRouter is the root of the tree
"""
type TRouter <: Router
    root::Endpoint
    middleware::Function
    TRouter() = new(StaticEndpoint(), basiccatch)
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
    for field in fieldname(typ)
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

handle! must return the handler function
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
finalize!(r::TRouter) = finalize!(r.root)

# TRouter specific helper functions
