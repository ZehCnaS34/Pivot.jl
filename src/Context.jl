type Context
    request::Request
    response::Response
    data::Dict{Any, Any}
    Context(req::Request) = new(req, Response(), Dict{Any, Any}())
end

"""
# Response(::Context)

converts the context to a response
"""
Response(ctx::Context) = ctx.response
