module DateUtils

import TimeZones: ZonedDateTime, Local, timezone, localtime, interpret
import Base: .+, +, .-, -

include("condense.jl")
include("hourofweek.jl")
include("arithmetic.jl")

export condense, hourofweek

end # module
