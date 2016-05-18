# importing
import Base.repr
import Base.in
import Base.(==)
import Base.(<)
import Base.(>)
import Base.isless
import Base.getindex
import Base.push!

# just a little type alias
typealias Handler Function

# The children should be sorted with static endpoints first
abstract Endpoint

const ROOT_TAG = "__pivot__"

# For debugging. Makes endpoints a little nicer looking in the terminal.
function repr(e::Endpoint, offset=0)
  val = (typeof(e) == StaticEndpoint) ?  "S" : "D"
  repeat("\t", offset) * "$(e.tag)-$val$offset-$(length(e.handlermap))-($((isempty(e.children))?"":"\n")" * join(map((ep) -> repr(ep, offset+1), e.children), "\n") * ")"
end

"""
StaticEndpoint
"""
type StaticEndpoint <: Endpoint
  tag
  children::Vector{Endpoint}
  handlermap::Dict{Verb, Handler}
  StaticEndpoint() = new(ROOT_TAG, [], Dict())
  StaticEndpoint(name) = new(name, [], Dict())
end

"""
DynamicEndpoint
matches any string and captures what it compares during a comparison check.
"""
type DynamicEndpoint <: Endpoint
  tag
  captured
  children::Vector{Endpoint}
  handlermap::Dict{Verb, Handler}
  DynamicEndpoint(name) = new(name, nothing, [], Dict())
end

(==)(tag::AbstractString, ep::StaticEndpoint) = tag == ep.tag
(==)(ep::StaticEndpoint, tag::AbstractString) = tag == ep.tag
(==)(tag::AbstractString, ep::DynamicEndpoint) = (ep.captured = tag; true)
(==)(ep::DynamicEndpoint, tag::AbstractString) = (ep.captured = tag; true)

"""
static endpoint should be less that a dynamic endpoint.
"""
isless(::StaticEndpoint, ::DynamicEndpoint) = true
isless(::DynamicEndpoint, ::StaticEndpoint) = false
isless(::StaticEndpoint, ::StaticEndpoint) = false
isless(::DynamicEndpoint, ::DynamicEndpoint) = false

"""
check if the tag is named
"""
Base.in(tag::AbstractString, ep::Endpoint) = in(tag, ep.children)

"""
getindex
returns the child with the specified tag name.
"""
function getindex(ep::Endpoint, tag::AbstractString)
  for cep in ep.children
    cep == tag && return cep
  end


  error("No endpoint named $tag.")
end

function getindex(
  ep::Endpoint, 
  tags::AbstractVector
)
  isempty(tags) && return ep
  leaf = ep[shift!(tags)]
  while !isempty(tags)
    leaf = leaf[shift!(tags)]
  end
  leaf
end


function getindex(
  ep::Endpoint, 
  tag::AbstractString, 
  captured::Dict{Any, Any}
)
  ret = ep[tag]
  if typeof(ret) == DynamicEndpoint
    captured[ret.tag[2:end]] = ret.captured
  end
  (ret, captured)
end

"""
getindex returns the child endpoint of the parent endpoint that
matches the string
"""
function getindex(
  ep::Endpoint, 
  tags::AbstractVector,
  captured::Dict{Any, Any}
)
  isempty(tags) && return (ep, captured)
  leaf, captured = ep[shift!(tags), captured]
  while !isempty(tags)
    leaf, captured = leaf[shift!(tags), captured]
  end
  leaf, captured
end

function push!(ep::Endpoint, o::Endpoint)
  if in(o.tag, ep)
    return ep[o.tag]
  end
  push!(ep.children, o)
  sort!(ep.children)
  o
end


"""
# push!
converts the tag into an endpoint, then pushes it the the chileren
of ep.
"""
function push!(ep::Endpoint, tag::AbstractString;
               dynamic_prefix=':')
  push!(ep, StaticEndpoint(tag))
  ep[tag]
end

"""
# push!

Takes a taglist::Vector{AbstractString}, shifts them one-by-one and pushes
the token onto the current endpoint, and returns
"""
function push!(ep::Endpoint, taglist::Vector)
  while !isempty(taglist)
    tag = shift!(taglist)
    ep = push!(ep, tag)
  end
  ep
end


"""
# buildtree

builds a routing tree from a taglist
"""
function buildtree(taglist::Vector; dynamic_identifer=':', root=StaticEndpoint())
  push!(root, taglist)
  return root
end

"""
# finalize!

this function converts the static endpoint nodes into dynamic endpoint
nodes.

This must be called after all of the routing is defined
# TODO: make iterative
"""
function finalize!(root::Endpoint; dynamic_prefix=':')
  #=println("Finalizing $(root.tag)")=#
  if startswith(root.tag, dynamic_prefix) && typeof(root) == StaticEndpoint
    children = root.children
    hm = root.handlermap
    root = DynamicEndpoint(root.tag)
    root.children = children
    root.handlermap = hm
  end
  root.children = map(finalize!, root.children)
  sort!(root.children)
  return root
end
