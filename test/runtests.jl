using Pivot
using Base.Test

# write your own tests here
@test GET == 1
@test PUT == 2
@test POST == 4
@test DELETE == 8
@test PATCH == 16

@test GET + POST == GET | POST == 5

root = StaticEndpoint()

@test Pivot.create_tree_from_token_chain(root, []) == root

home_endpoint = StaticEndpoint("home")
rootc = deepcopy(root)
push!(rootc.children, home_endpoint)

@test Pivot.create_tree_from_token_chain(root, ["home"]) == home_endpoint
@test rootc != root
