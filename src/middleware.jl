module Logger

"""
# simple
assumes that the proper engine middleware is included
"""
function simple(ap, ctx)
  println("[$(ctx[:request][:method])]\n[$(ctx[:request][:path])]\n[$(ctx[:request][:query])]")
  ap(ctx)
end

end
