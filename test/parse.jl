using Compat.Dates

@testset "parse Period" begin
    @test parse(Period, "Year(1)") == Year(1)
    @test parse(Period, "Year(-1)") == Year(-1)
    @test_throws ArgumentError parse(Period, "-Year(1)")
    @test_throws ArgumentError parse(Period, "Beat(1)")

    for (name, T) in DateUtils.STRING_TO_PERIOD
        @test parse(Period, "$name(0)") == T(0)
    end
end
