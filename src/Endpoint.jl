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
function repr(e::Endpoint)
  "$(e.tag)(" * join(map(repr, e.children), ",") * ")"
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

"""
getindex returns the child endpoint of the parent endpoint that
matches the string
"""
function getindex(ep::Endpoint, tags::Vector; eqfn=(a,b) -> true)
  isempty(tags) && return ep
  leaf = ep[shift!(tags)]
  while !isempty(tags)
    leaf = leaf[shift!(tags)]
  end
  leaf
end

function push!(ep::Endpoint, o::Endpoint)
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
  # only push as static
  #=if !in(tag,ep)=#
    #=if startswith(tag, dynamic_prefix)=#
      #=push!(ep, DynamicEndpoint(tag))=#
    #=else=#
      #=push!(ep, StaticEndpoint(tag))=#
    #=end=#
  #=end=#
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
  if startswith(root.tag, dynamic_prefix) && typeof(root) == StaticEndpoint
    children = root.children
    hm = root.handlermap
    root = DynamicEndpoint(root.tag)
    root.children = children
    root.handlermap = hm
  end
  root.children = map(finalize!, root.children)
  return root
end
