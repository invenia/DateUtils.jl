using DateUtils
using Compat.Test

@testset "DateUtils" begin
    include("condense.jl")
    include("hourofweek.jl")
    include("parse.jl")
end
