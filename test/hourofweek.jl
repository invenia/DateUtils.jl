using TimeZones


utc = TimeZone("UTC")
winnipeg = TimeZone("America/Winnipeg")


dt = DateTime(2016, 8, 1)   # Monday
for h in 0:167
    @test hourofweek(dt + Hour(h)) == h
    @test hourofweek(ZonedDateTime(dt + Hour(h), utc)) == h
    @test hourofweek(ZonedDateTime(dt + Hour(h), winnipeg)) == h
end
@test hourofweek(DateTime(2016, 8, 2)) == hourofweek(DateTime(2016, 8, 2, 0, 59, 59, 999))
