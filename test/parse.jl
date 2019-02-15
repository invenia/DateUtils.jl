using Dates
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
    dt_a = DateTime(2019, 1, 18, 16)
    dt_b = DateTime(2019, 1, 18, 16, 46, 12, 285)
    zdt_a = ZonedDateTime(dt_a, tz"America/Winnipeg")
    zdt_b = ZonedDateTime(dt_b, tz"America/Winnipeg")

    @testset "_parse DateTime" begin
        # Test that date formating and stringification hasn't changed
        @test Dates.format(dt_a, Dates.ISODateTimeFormat) == "2019-01-18T16:00:00.0"
        @test Dates.format(dt_b, Dates.ISODateTimeFormat) == "2019-01-18T16:46:12.285"
        @test string(dt_a) == "2019-01-18T16:00:00"
        @test string(dt_b) == "2019-01-18T16:46:12.285"

        # Test that _parse works like normal datetime parsing
        @test DateUtils._parse(DateTime, "2019-01-18T16:00:00.0") == parse(DateTime, "2019-01-18T16:00:00.0")
        @test DateUtils._parse(DateTime, "2019-01-18T16:46:12.285") == parse(DateTime, "2019-01-18T16:46:12.285")

        # Missing milliseconds test
        @test DateUtils._parse(DateTime, "2019-01-18T16:00:00") == parse(DateTime, "2019-01-18T16:00:00")
    end

    @testset "_parse ZonedDateTime" begin
        @test Dates.format(zdt_a, TimeZones.ISOZonedDateTimeFormat) == "2019-01-18T16:00:00.000-06:00"
        @test Dates.format(zdt_b, TimeZones.ISOZonedDateTimeFormat) == "2019-01-18T16:46:12.285-06:00"
        @test string(zdt_b) == "2019-01-18T16:46:12.285-06:00"
        @test string(zdt_a) == "2019-01-18T16:00:00-06:00"

        @test DateUtils._parse(ZonedDateTime, "2019-01-18T16:00:00.000-06:00") == parse(ZonedDateTime, "2019-01-18T16:00:00.000-06:00")
        @test DateUtils._parse(ZonedDateTime, "2019-01-18T16:46:12.285-06:00") == parse(ZonedDateTime, "2019-01-18T16:46:12.285-06:00")

        # Missing milliseconds test
        @test DateUtils._parse(ZonedDateTime, "2019-01-18T16:00:00-06:00") == parse(ZonedDateTime, "2019-01-18T16:00:00.000-06:00")
        @test_throws ArgumentError parse(ZonedDateTime, "2019-01-18T16:00:00-06:00")
    end

    anchored_intervals = [HE.((dt_a, dt_b, zdt_a, zdt_b))..., HB.((dt_a, dt_b, zdt_a, zdt_b))...]
    @testset "parse AnchoredInterval" begin
        for i in anchored_intervals
            @test parse(typeof(i), string(i)) == i
        end
    end

    intervals = [Interval(x, x + Hour(1)) for x in (dt_a, dt_b, zdt_a, zdt_b)]
    @testset "parse Interval" begin
        for i in intervals
            @test parse(typeof(i), string(i)) == i
        end
    end
end
