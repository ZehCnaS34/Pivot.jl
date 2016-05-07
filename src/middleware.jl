module Logger

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

"""
Defines the proper variables for the template home
"""
function template(template_directory)
  function (app, ctx)
    ctx[:template_dir] = abspath(template_directory)
    app(ctx)
  end
end

"""
# public serve some static files?
"""
function public(public_directory)
  function (app, req)
    resourcefile = joinpath(public_directory,
      join(req[:path], "/")) |> abspath

    if isfile(resourcefile)
      f = open(resourcefile)
      content = join(readlines(f), "")
      close(f)
      return content
    end

    app(req)
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
