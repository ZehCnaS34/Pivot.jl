using Pivot
using Base.Test

# write your own tests here
@test GET == 1
@test PUT == 2
@test POST == 4
@test DELETE == 8
@test PATCH == 16

@test GET + POST == GET | POST == 5

@testset "Endpoint" begin
end
