include("middleware/Security.jl")
include("middleware/Filter.jl")
include("middleware/Logging.jl")
module Static

using Mustache
export render
import HttpServer: Response, mimetypes

"""
Defines the proper variables for the template home
"""
function template(template_directory)
  function (app, ctx)
    ctx[:template_dir] = abspath(template_directory)
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
    resourcefile = joinpath(public_directory,
      join(ctx[:request][:path], "/")) |> abspath

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
# render

should render a file as a request

later on, I should deff cache this
"""
function render(ctx, filename, data=Dict())
  template_location = ctx[:template_dir]
  f = open(joinpath(template_location, filename))
  content = join(readlines(f), "")
  close(f)
  Mustache.render(content, data)
end

end
