module Routing
using Pivot
export redirect_to

# TODO: make this DRY
function redirect_to(ctx, route)
  path = split(route, "/", keep=false)
  ep, params = fetch(ctx.data[:router], path)
  method = Pivot.STI[ctx.data[:request][:method]]
  ctx.data[:params] = params
  ctx |> Pivot.proper_method(method, ep.handlermap)
end


"""
# make_partial_route

build an incomplete `handle!` method call
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

macro resources(phandler)
  base_url = phandler.args[1]
  controller = phandler.args[2]
  if endswith(base_url, "/")
    base_url = base_url[1:end-1]
  end


  quote
    [
    @get    $(base_url)               => $(esc(Expr(:., controller, :(:index   ))))
    @get    $(base_url * "/new")      => $(esc(Expr(:., controller, :(:new     ))))
    @post   $(base_url)               => $(esc(Expr(:., controller, :(:create  ))))
    @get    $(base_url * "/:id")      => $(esc(Expr(:., controller, :(:show    ))))
    @get    $(base_url * "/:id/edit") => $(esc(Expr(:., controller, :(:edit    ))))
    @put    $(base_url * "/:id")      => $(esc(Expr(:., controller, :(:update  ))))
    @delete $(base_url * "/:id")      => $(esc(Expr(:., controller, :(:destroy ))))
    ]
  end
end


end
