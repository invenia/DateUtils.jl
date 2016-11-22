"""
  hourofweek(dt::TimeType) -> Int64

Returns the hour of the week as an Int64 in the range 0 through 167.

For locales in which weeks can have more or fewer than 168 hours (those that observe DST),
two consecutive hours may return the same result or an integer may be skipped, as the case
may be.
"""
hourofweek(d::TimeType) = (dayofweek(d) - 1) * 24 + hour(d)
