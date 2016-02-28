
import Base.in


abstract Endpoint

# returns 0 if the element does not exist in the array.
# O[n]
function indexof(elt, list)
  for i in list
    list[i] == elt && return i
  end

  return 0
end

type StaticEndpoint <: Endpoint
  tag
  children::Vector{Endpoint}
  handlermap::Map{Int16, Handler}
  StaticEndpoint() = new("/", [])
end

function Base.in(tag, es::Vector{Endpoint})
  tags = map((t) -> t.tag ,es)
  in(tag, tags)
end

function Base.in(fn, val, es::Vector{Endpoint})
  for ep in es
    val == fn(ep) && return true
  end
  return false
end

function getchild(tag, es::Vector{Endpoint})
  for ep in es
    tag == ep.tag && return ep
  end

  nothing
end

"""
@params tag_list::
Returns an endpoint
"""
function crawl_node_chain(e::Endpoint, tag_list)
  isempty(tag_list) && return e
  token = pop!(tag_list)
  in(token, e.children) do ep
    ep.tag
  end && return crawl_node_chain(getchild(token, e.children), tag_list)
end

crawl_node_chain(::Void, tag_list) = throw("Testing")
