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
        # Test that date formating and stringification hasn't changed
        @test "2019-01-18T16:00:00.0" == Dates.format(a, Dates.ISODateTimeFormat)
        @test "2019-01-18T16:46:12.285" == Dates.format(b, Dates.ISODateTimeFormat)
        @test "2019-01-18T16:00:00" == string(a)
        @test "2019-01-18T16:46:12.285" == string(b)

        # Test that _parse works like normal datetime parsing
        @test DateUtils._parse(DateTime, "2019-01-18T16:00:00.0") == parse(DateTime, "2019-01-18T16:00:00.0")
        @test DateUtils._parse(DateTime, "2019-01-18T16:46:12.285") == parse(DateTime, "2019-01-18T16:46:12.285")

        # Missing milliseconds test
        @test DateUtils._parse(DateTime, "2019-01-18T16:00:00") == parse(DateTime, "2019-01-18T16:00:00")
    end

    @testset "_parse ZonedDateTime" begin
        @test "2019-01-18T16:00:00.000-06:00" == Dates.format(x, TimeZones.ISOZonedDateTimeFormat)
        @test "2019-01-18T16:46:12.285-06:00" == Dates.format(y, TimeZones.ISOZonedDateTimeFormat)
        @test "2019-01-18T16:46:12.285-06:00" == string(y)
        @test "2019-01-18T16:00:00-06:00" == string(x)

        @test DateUtils._parse(ZonedDateTime, "2019-01-18T16:00:00.000-06:00") == parse(ZonedDateTime, "2019-01-18T16:00:00.000-06:00")
        @test DateUtils._parse(ZonedDateTime, "2019-01-18T16:46:12.285-06:00") == parse(ZonedDateTime, "2019-01-18T16:46:12.285-06:00")

        # Missing milliseconds test
        @test DateUtils._parse(ZonedDateTime, "2019-01-18T16:00:00-06:00") == parse(ZonedDateTime, "2019-01-18T16:00:00.000-06:00")
        @test_throws ArgumentError parse(ZonedDateTime, "2019-01-18T16:00:00-06:00")
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
