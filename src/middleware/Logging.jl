module Logger
import HttpServer.mimetypes

function print_rgb(r, g, b, t)
    print("\e[1m\e[38;2;$r;$g;$b;249m",t)
end

random_color(msg) = print_rgb(rand(1:256), rand(1:256), rand(1:256), msg)

"""
# simple
assumes that the proper engine middleware is included
"""
function simple(ap::Function, ctx)
  s = time()
  output =  ap(ctx)
  f = time()
  random_color("[$(ctx.data[:request][:method]) $(join(ctx.data[:request][:path], "/") * "/")] -- $(f - s) (s)\n")
  output
end


end
