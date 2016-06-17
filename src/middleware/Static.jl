module Static

export render
import HttpServer: Response, mimetypes


function mime(s)
    if in(s, mimetypes |> keys)
        return mimetypes[s]
    end
    "text/plain"
end


"""
# public serve some static files?
"""
function public(public_directory)
    function (app, ctx)
        ctx.data[:public_dir] = public_directory
        resourcefile = joinpath(public_directory,
                                join(ctx.data[:request][:path], "/")) |> abspath

        if isfile(resourcefile)
            ext = split(resourcefile |> basename, ".")[end]
            f = open(resourcefile)
            res = (join(readall(resourcefile), ""))
            close(f)
            ctx.response.headers["Content-Type"] = mime(ext) * "; charset=utf-8"
            return res
        end

        app(ctx)
    end
end

"""
# favicon

for this to work, you need to have the public middleware installed
"""
function favicon(app, ctx)
    if join(ctx.data[:request][:path], "/") == "favicon.ico"
        return "awesome" # this should be the location of a favicon
    end

    app(ctx)
end



end
