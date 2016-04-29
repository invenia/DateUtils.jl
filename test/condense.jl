using Base.Dates

@test DateUtils.condense(Hour(24)) == Day(1)
@test DateUtils.condense(Hour(25)) == Hour(25)
