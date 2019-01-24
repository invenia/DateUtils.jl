using Compat.Dates

const STRING_TO_PERIOD = Dict(
    "Year" => Year,
    "Month" => Month,
    "Week" => Week,
    "Day" => Day,
    "Hour" => Hour,
    "Minute" => Minute,
    "Second" => Second,
    "Millisecond" => Millisecond,
    "Nanosecond" => Nanosecond,
)

# Working on incorporating this into base
_regex(re::Regex...) = Regex(string([r.pattern for r in re]...))

# Regex components for our interval parsing
const LEFT_INC_RE = r"^(?<linc>\[|\()"
const RIGHT_INC_RE = r"(?<rinc>\]|\))$"
const DATE_RE = r"(?<yyyy>\d{4})-(?<mm>\d{1,2})-(?<dd>\d{1,2})"
const HR_RE = r" (?<HR>H[EB])(?<hr>\d{1,2})"
const TZ_RE = r"(?<tz>[+-][\d|:]+)"
# "(2018-12-02T23:00:00-06:00 .. 2018-12-03T00:00:00-06:00]"
const INTERVAL_RE = _regex(LEFT_INC_RE, r"(?<ldate>[\d\-T:.]+) .. (?<rdate>[\d\-T:.]+)", RIGHT_INC_RE)
# "[2019-01-18 HB16)"
const ANCHORED_RE = _regex(LEFT_INC_RE, DATE_RE, HR_RE, r".*", RIGHT_INC_RE)
# "[2019-01-18 HB16-06:00)"
const ANCHORED_TZ_RE = _regex(LEFT_INC_RE, DATE_RE, HR_RE, TZ_RE, RIGHT_INC_RE)
# "2019-01-18T17:00:00-06:00"
const ZDT_RE = _regex(r"^(?<dt>[\d\-]+T[\d:]+)(?<ms>.\d{1,3})?(?<tz>[+-][[\d:]+)$")


function Base.parse(::Type{Period}, str::AbstractString)
    m = match(r"^(?<type>\w+)\((?<value>-?\d+)\)$", str)

    if m !== nothing
        if haskey(STRING_TO_PERIOD, m[:type])
            T = STRING_TO_PERIOD[m[:type]]
        else
            throw(ArgumentError("Unknown type provided: $(m[:type])"))
        end

        return T(parse(Int, m[:value]))
    else
        throw(ArgumentError("Cannot parse period of: $str"))
    end
end

#=
Code for parsing intervals with a focus on testing DateTimes and ZonedDateTimes

While we can handle the milliseconds issue with ZonedDateTimes, you should call
```
Dates.format(dt, Dates.ISODateTimeFormat)
```
or
```
Dates.format(zdt, TimeZones.ISOZonedDateTimeFormat)
```
to ensure that you're output strings are parsable.
=#

function Base.parse(::Type{Interval{T}}, str::AbstractString) where T
    m = match(INTERVAL_RE, str)

    if m === nothing
        throw(ArgumentError("Failed to parse Interval string $str w/ $re"))
    end

    return Interval(
        _parse(T, m[:ldate]), _parse(T, m[:rdate]), m[:linc] == "[", m[:rinc] == "]"
    )
end

function Base.parse(
    I::Type{<:Union{HourBeginning{T}, HourEnding{T}}}, str::AbstractString
) where T <: DateTime
    a, b, f, dt, m = _extract(I, ANCHORED_RE, str)
    return f(DateTime(dt...), a, b)
end

function Base.parse(
    I::Type{<:Union{HourBeginning{T}, HourEnding{T}}}, str::AbstractString
) where T <: ZonedDateTime
    a, b, f, dt, m = _extract(I, ANCHORED_TZ_RE, str)
    return f(ZonedDateTime(dt..., FixedTimeZone(m[7])), a, b)
end

_parse(::Type{T}, str::AbstractString) where T = parse(T, str)

function _parse(::Type{T}, str::AbstractString) where T <: ZonedDateTime
    #=
    Handle splitting up and inserting the milliseconds when they aren't in the string.

    Example: "2019-01-18T17:00:00-06:00" -> parse(ZonedDateTime, "2019-01-18T17:00:00.000-06:00")
    =#
    m = match(ZDT_RE, str)

    if m === nothing
        throw(ArgumentError("Failed to parse ZonedDateTime string $str w/ $re"))
    end

    ms = m[:ms] === nothing ? ".000" : m[:ms]
    s = string(m[:dt], ms, m[:tz])
    parse(T, s)
end

function _extract(::Type{<:AnchoredInterval}, re::Regex, str::AbstractString)
    m = match(re, str)

    if m === nothing
        throw(ArgumentError("Failed to parse AnchoredInterval string $str w/ $re"))
    end

    a = m[:linc] == "["
    b = m[:rinc] == "]"
    f = if m[:HR] == "HE"
        HE
    elseif m[:HR] == "HB"
        HB
    else
        throw(ArgumentError("Unknown anchored interval abbreviation: $(m[:HR])"))
    end

    dt = parse.(Int, [m[:yyyy], m[:mm], m[:dd], m[:hr]])

    return a, b, f, dt, m
end
