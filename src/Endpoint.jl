# importing
import Base.repr
import Base.in
import Base.(==)
import Base.(<)
import Base.(>)
import Base.isless
import Base.getindex
import Base.push!

typealias Handler Function

# The children should be sorted with static endpoints first
abstract Endpoint

const ROOT_TAG = "__pivot__"

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

type DynamicEndpoint <: Endpoint
  tag
  captured
  children::Vector{Endpoint}
  handlermap::Dict{Verb, Handler}
  DynamicEndpoint(name) = new(name, nothing, [], Dict())
end

# @ord (
#   StaticEndpoint,
#   DynamicEndpoint
# )

(==)(tag::AbstractString, ep::StaticEndpoint) = tag == ep.tag
(==)(ep::StaticEndpoint, tag::AbstractString) = tag == ep.tag
(==)(tag::AbstractString, ep::DynamicEndpoint) = (ep.captured = tag; true)
(==)(ep::DynamicEndpoint, tag::AbstractString) = (ep.captured = tag; true)

isless(::StaticEndpoint, ::DynamicEndpoint) = true
isless(::DynamicEndpoint, ::StaticEndpoint) = false
isless(::StaticEndpoint, ::StaticEndpoint) = false
isless(::DynamicEndpoint, ::DynamicEndpoint) = false
# (>)(::StaticEndpoint, ::DynamicEndpoint) = false
# (>)(::DynamicEndpoint, ::StaticEndpoint) = true

"""
check if the tag is named
"""
Base.in(tag::AbstractString, ep::Endpoint) = in(tag, ep.children)

function getindex(ep::Endpoint, tag::AbstractString)
  for cep in ep.children
    cep == tag && return cep
  end

  error("no endpoint named $tag.")
end

"""
getindex returns the child endpoint of the parent endpoint that
matches the string
"""
function getindex(ep::Endpoint, tags::Vector)
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
end

function push!(ep::Endpoint, tag::AbstractString;
              dynamic_prefix=':')
  if !in(tag,ep)
    if startswith(tag, dynamic_prefix)
      push!(ep, DynamicEndpoint(tag))
    else
      push!(ep, StaticEndpoint(tag))
    end
  end
  ep[tag]
end

function push!(ep::Endpoint, taglist::Vector)
  while !isempty(taglist)
    tag = shift!(taglist)
    ep = push!(ep, tag)
  end
  ep
end

function buildtree(taglist::Vector; dynamic_identifer=':')
  root = StaticEndpoint()
  push!(root, taglist)
  return root
end
