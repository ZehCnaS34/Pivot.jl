module Static

using Mustache
export render
import HttpServer: Response, mimetypes

"""
Defines the proper variables for the template home
"""
function template(template_directory)
    function (app, ctx)
        ctx.data[:template_dir] = abspath(template_directory)
        app(ctx)
    end
end


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
            res = Response(join(readlines(f), ""))
            close(f)
            res.headers["Content-Type"] = mime(ext) * "; charset=utf-8"
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



"""
# render

should render a file as a request

later on, I should deff cache this
"""
function render(ctx, filename, data=Dict())
    template_location = ctx.data[:template_dir]
    f = open(joinpath(template_location, filename))
    content = join(readlines(f), "")
    close(f)
    Mustache.render(content, data)
end

end
