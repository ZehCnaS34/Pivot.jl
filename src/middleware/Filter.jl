"""
Filter contains middleware that is able to mutate the request map.
These functions are most commonly used to make accessing data from the request more simple and straight forward.
"""
module Filter

using HttpServer
import HttpCommon: Cookie

"""
# strtodict

converts
"""
function strtodict(str, delim)
    str = split(str, delim)
    str = map((kv) -> split(kv, "="), str)
    str = filter((l) -> length(l) > 1, str)
    [ strip(k) => v for (k, v) in str ]
end


"""
# parse_multipart
"""
function parse_multipart(raw, boundary)
    println(raw)
    raw = convert(ASCIIString, raw)
    raw = split(raw, "\r\n")
    raw = map(strip, raw)
    raw = map((kv) -> split(kv, boundary), raw)
    # str = filter((l) -> length(l) > 1, str)
    println(raw)
    [ strip(k) => v for (k, v) in raw ]
end

"""
# body_todict(app, ctx)

Converts the query from the request to a dictionary. Then stores in to locations
```julia
ctx.data[:request][:data] ## overwriting the raw version
ctx.data[:body] ## for convenience
```
"""
function body_todict(app, ctx)
    if !in(:data, ctx.data[:request] |> keys)
        ctx.data[:data] = Dict()
        return app(ctx)
    end

    if :type in keys(ctx.data[:contenttype])
        raw_data = convert(ASCIIString, ctx.data[:request][:data])

        ctx.data[:body] = if ctx.data[:contenttype][:type] != "multipart"
            strtodict(raw_data, "&")
        else
            parse_multipart(raw_data,
                            ctx.data[:contenttype][:parameters]["boundary"])
        end

        return app(ctx)
    end

    raw_data = convert(ASCIIString, ctx.data[:request][:data])
    data = strtodict(raw_data, "&")
    ctx.data[:body] = data
    app(ctx)
end


# hacky
function contenttype_todict(app, ctx)
    if !in("Content-Type", ctx.data[:request][:headers] |> keys)
        ctx.data[:contenttype] = Dict()
        return app(ctx)
    end

    ct = Dict()


    raw_data = convert(ASCIIString, ctx.data[:request][:headers]["Content-Type"])

    println(raw_data)

    parts = split(raw_data, ";")
    ct[:parameters] = length(parts) > 1 ?
        strtodict(parts[2], ";") :
        Dict()

    types                  = split(parts[1], "/")
    ct[:type]              = types[1]
    ct[:subtype]           = types[2]
    ctx.data[:contenttype] = ct
    app(ctx)
end


"""
# body_todict(app, ctx)

Converts the query from the request to a dictionary. Then stores in to locations
```julia
ctx.data[:request][:cookie] ## overwriting the raw version
ctx.data[:cookie] ## for convenience
```
"""
function cookie_todict(app::Function, ctx)
    if !in("Cookie", keys(ctx.data[:request][:headers]))
        ctx.data[:cookies] = Dict()
        resp = app(ctx)
        return resp
    end
    dough = ctx.data[:request][:headers]["Cookie"]
    cookie = strtodict(dough, "; ")
    ctx.data[:cookies] = cookie

    resp = app(ctx)

    # adding new cookies added from the handler to the response
    for (k, v) in ctx.data[:cookies]
        ctx.response.cookies[string(k)] = Cookie(k, v)
    end
    return resp
end



"""
# query_todict

Converts the query from the request to a dictionary. Then stores in to locations
```julia
ctx.data[:request][:query] ## overwriting the raw version
ctx.data[:query] ## for convenience
```
"""
function query_todict(app::Function, ctx)
    raw_query = ctx.data[:request][:query]
    marshalled = strtodict(raw_query, "&")
    ctx.data[:request][:query] = marshalled
    ctx.data[:query]           = marshalled
    app(ctx)
end

function mime!(ctx, value::AbstractString)
    ctx.response.headers["Content-Type"] = value * "; charset=utf-8"

end

end
