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

# Regex components for our interval parsing
const LEFT_INC_RE = r"^(\[|\()"
const RIGHT_INC_RE = r"(\]|\))$"
const DATE_RE = r"(\d{4})-(\d{1,2})-(\d{1,2})"
const HR_RE = r" (H[EB])(\d{1,2})"
const TZ_RE = r"([+-][\d|:]+)"

# Working on incorporating this into base
_regex(re::Regex...) = Regex(string([r.pattern for r in re]...))

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
    #=
    Example: "(2018-12-02T23:00:00-06:00 .. 2018-12-03T00:00:00-06:00]"
    =#
    re = _regex(LEFT_INC_RE, r"([\d\-T:.]+) .. ([\d\-T:.]+)", RIGHT_INC_RE)
    m = match(re, str)

    if m === nothing
        throw(ArgumentError("Failed to parse Interval string $str w/ $re"))
    end

    a, f, l, b = m.captures
    return Interval(_parse(T, f), _parse(T, l), a == "[", b == "]")
end

function Base.parse(
    I::Type{<:Union{HourBeginning{T}, HourEnding{T}}}, str::AbstractString
) where T <: DateTime
    #=
    Example: "[2019-01-18 HB16)"
    =#
    re = _regex(LEFT_INC_RE, DATE_RE, HR_RE, r".*", RIGHT_INC_RE)
    a, b, f, dt, m = _extract(I, re, str)

    return f(DateTime(dt...), a, b)
end

function Base.parse(
    I::Type{<:Union{HourBeginning{T}, HourEnding{T}}}, str::AbstractString
) where T <: ZonedDateTime
    #=
    Example: "[2019-01-18 HB16-06:00)"
    =#
    re = _regex(LEFT_INC_RE, DATE_RE, HR_RE, TZ_RE, RIGHT_INC_RE)
    a, b, f, dt, m = _extract(I, re, str)
    return f(ZonedDateTime(dt..., FixedTimeZone(m[7])), a, b)
end

_parse(::Type{T}, str::AbstractString) where T = parse(T, str)

function _parse(::Type{T}, str::AbstractString) where T <: ZonedDateTime
    #=
    Handle splitting up and inserting the milliseconds when they aren't in the string.

    Example: "2019-01-18T17:00:00-06:00" -> parse(ZonedDateTime, "2019-01-18T17:00:00.000-06:00")
    =#
    re = _regex(r"^([\d\-]+T[\d:]+)(.\d{1,3})?([+-][[\d:]+)$")
    m = match(re, str)

    if m == nothing
        throw(ArgumentError("Failed to parse ZonedDateTime string $str w/ $re"))
    end

    ms = m[2] === nothing ? ".000" : m[2]
    s = string(m[1], ms, m[3])
    parse(T, s)
end

function _extract(::Type{<:AnchoredInterval}, re::Regex, str::AbstractString)
    m = match(re, str)

    if m === nothing
        throw(ArgumentError("Failed to parse AnchoredInterval string $str w/ $re"))
    end

    a = m[1] == "["
    b = m.captures[end] == "]"
    f = m[5] == "HE" ? HE : HB
    dt = parse.(Int, m.captures[[2, 3, 4, 6]])

    return a, b, f, dt, m
end
