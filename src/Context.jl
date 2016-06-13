type Context
    request::Request
    response::Response
    data::Dict{Symbol, AbstractString}
end

Context(req::Request) = Context(req, Response(), Dict{Symbol, AbstractString}())


"""
# Response(::Context)

converts the context to a response
"""
Response(ctx::Context) = ctx.response
