import Base.fetch
abstract Router

"""
# Mount
takes one routing tree `r2` and attaches it to another routing tree `r1`
the mount will applied according to the specified path `to`

return returns the leaf node
"""
function mount!(r1::Router, r2::Router; to="/")
  error("mount! not implemented.")
end


"""
# handle!

attaches the handler::Function to the handlemap contained on the leaf endpoint
of the path.
"""
function handle!(
  fn::Handler,
  ep::Endpoint,
  method::Verb
)
  error("handle!(::Handler, ::Endpoint, ::Verb) implemented")
end

function handle!(
  fn::Handler,
  router::Router,
  method::Verb,
  path::Vector
)
  error("handle!(::Handler, ::Router, ::Verb, ::Vector) implemented")
end

handle!(
  fn::Handler,
  router::Router,
  method::Verb,
  path::AbstractString
) = handle!(fn, router, method, parseurl(path))

handle!(
  router::Router,
  fn::Handler,
  method::Verb,
  path::AbstractString
) = handle!(fn, router, method, parseurl(path))

function use!(router::Router, fn::Function)
  error("use! is not implemented.")
end

use!(fn::Function, r::Router) = use!(r, fn)
fetch(r::Router, tokens::Vector) =
finalize!(r::TRouter) = error("finalize! not implemented.")

# Router specific helper functions
