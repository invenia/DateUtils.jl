module DateUtils

using Compat: AbstractDateTime
using Intervals
using TimeZones: FixedTimeZone, ZonedDateTime, Local, timezone, localtime, interpret

include("condense.jl")
include("hourofweek.jl")
include("parse.jl")

export condense, hourofweek

end  # module
