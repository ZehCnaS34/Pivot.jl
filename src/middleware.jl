module Logger
import HttpServer.mimetypes

"""
# simple
assumes that the proper engine middleware is included
"""
function simple(ap, ctx)
  s = time()
  output =  ap(ctx)
  f = time()
  println("[$(ctx[:request][:method]) $(join(ctx[:request][:path], "/") * "/")] -- $(f - s) (s)")
  output
end

end

module Static
export render
import HttpServer.Response

"""
Defines the proper variables for the template home
"""
function template(template_directory)
  function (app, ctx)
    ctx[:template_dir] = abspath(template_directory)
    app(ctx)
  end
end

const ETM = Dict(
  "js"   => "application/javascript",
  "css"  => "text/css",
  "html" => "text/html"
)

function etm(s)
  if in(s, mimetypes)
    return ETM[s]
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
      res.headers["Content-Type"] = etm(ext) * "; charset=utf-8"
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
function render(ctx, filename)
  template_location = ctx[:template_dir]
  f = open(joinpath(template_location, filename))
  content = join(readlines(f), "")
  close(f)
  content
end

end
