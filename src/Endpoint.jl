
import Base.in

typealias Handler Function

abstract Endpoint
const ROOT_TAG = "__pivot__"

# returns 0 if the element does not exist in the array.
# O[n]
function indexof(elt, list)
  for i in list
    list[i] == elt && return i
  end

  return 0
end

"""
StaticEndpoint
"""
type StaticEndpoint <: Endpoint
  tag
  children::Vector{Endpoint}
  handlermap::Dict{Int16, Handler}
  StaticEndpoint() = new(ROOT_TAG, [], Dict())
  StaticEndpoint(name) = new(name, [], Dict())
end

function Base.in(tag, ep::Endpoint)
  for c in ep.children
    tag == c.tag && return true
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
The `crawl_node_chain` function takes an endpointNode and a tag list, and
returns the last endpoint in the tag list. It returns nothing, if the endpoint
does not exist

  crawl_node_chain(StaticEndpoint(), ["users", ":id", "show"])
"""
function crawl_node_chain(e::Endpoint, tag_list)
  isempty(tag_list) && return e
  token = pop!(tag_list)
  in(token, e.children) do ep
    ep.tag
  end && return crawl_node_chain(getchild(token, e.children), tag_list)
end

"""
Returns the leaf node for the last token in the taglist
if there is no link to the leaf node, It will be generated.
"""
function create_tree_from_token_chain(ep, taglist)
  isempty(taglist) && return ep
  tag = shift!(taglist)
  in(tag, ep) && return create_tree_from_token_chain(getchild(tag, ep), taglist)
  child = StaticEndpoint(tag)
  push!(ep.children, child)
  return create_tree_from_token_chain(child, taglist)
end

crawl_node_chain(::Void, tag_list) = nothing
