using Compat.Dates
using Intervals
using TimeZones

@testset "parse Period" begin
    @test parse(Period, "Year(1)") == Year(1)
    @test parse(Period, "Year(-1)") == Year(-1)
    @test_throws ArgumentError parse(Period, "-Year(1)")
    @test_throws ArgumentError parse(Period, "Beat(1)")

    for (name, T) in DateUtils.STRING_TO_PERIOD
        @test parse(Period, "$name(0)") == T(0)
    end
end

@testset "parse datetimes" begin
    a = DateTime(2019, 1, 18, 16)
    b = DateTime(2019, 1, 18, 16, 46, 12, 285)
    x = ZonedDateTime(a, tz"America/Winnipeg")
    y = ZonedDateTime(b, tz"America/Winnipeg")

    @testset "_parse DateTime" begin
        @test DateUtils._parse(DateTime, string(a)) == parse(DateTime, Dates.format(a, Dates.ISODateTimeFormat))
        @test DateUtils._parse(DateTime, string(b)) == parse(DateTime, Dates.format(b, Dates.ISODateTimeFormat))
        @test DateUtils._parse(DateTime, string(b)) == parse(DateTime, string(b))
        @test DateUtils._parse(DateTime, string(a)) == parse(DateTime, string(a))     # Does this error?
    end

    @testset "_parse ZonedDateTime" begin
        @test DateUtils._parse(ZonedDateTime, string(x)) == parse(ZonedDateTime, Dates.format(x, TimeZones.ISOZonedDateTimeFormat))
        @test DateUtils._parse(ZonedDateTime, string(y)) == parse(ZonedDateTime, Dates.format(y, TimeZones.ISOZonedDateTimeFormat))
        @test DateUtils._parse(ZonedDateTime, string(y)) == parse(ZonedDateTime, string(y))
        @test DateUtils._parse(ZonedDateTime, string(x)) == x
        @test_throws ArgumentError parse(ZonedDateTime, string(x))
    end

    anchored_intervals = [HE.((a, b, x, y))..., HB.((a, b, x, y))...]
    @testset "parse AnchoredInterval" begin
        for i in anchored_intervals
            @test parse(typeof(i), string(i)) == i
        end
    end

    intervals = [Interval(x, x + Hour(1)) for x in (a, b, x, y)]
    @testset "parse Interval" begin
        for i in intervals
            @test parse(typeof(i), string(i)) == i
        end
    end
end
