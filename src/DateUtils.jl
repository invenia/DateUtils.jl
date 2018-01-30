module DateUtils

import TimeZones: ZonedDateTime, Local, timezone, localtime, interpret

include("condense.jl")
include("hourofweek.jl")

export condense, hourofweek

end  # module
