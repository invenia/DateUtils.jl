using DateUtils
using Test

@testset "DateUtils" begin
    include("condense.jl")
    include("hourofweek.jl")
    include("parse.jl")
end
