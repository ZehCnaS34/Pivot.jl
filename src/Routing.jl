module Routing
using Pivot
export redirect_to

function redirect_to(ctx, route)
  path = split(route, "/", keep=false)
  ep, params= fetch(ctx[:router], path)
  method = Pivot.STI[ctx[:method]]
  ctx[:params] = params
  ctx |> Pivot.proper_method(method, ep.handlermap)
end


"""
# make_partial_route

build a 
"""
function make_partial_route(method, path, handler)
  :(handle!($(handler), $(method), $(path)))
end

"""
# get

"/" => HomeController.index
"""
macro get(phandler)
  :(make_partial_route(GET, $(phandler.args[1]), $(esc(phandler.args[2]))))
end

macro post(phandler)
  :(make_partial_route(POST, $(phandler.args[1]), $(esc(phandler.args[2]))))
end

macro put(phandler)
  :(make_partial_route(PUT, $(phandler.args[1]), $(esc(phandler.args[2]))))
end

macro delete(phandler)
  :(make_partial_route(DELETE, $(phandler.args[1]), $(esc(phandler.args[2]))))
end


end
