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

In order to guarantee that datetime parsing will work properly you'll need to call
```
Dates.format(dt, Dates.ISODateTimeFormat)
```
and
```
Dates.format(zdt, TimeZones.ISOZonedDateTimeFormat)
```
when generating the strings.

NOTE: We can currently handle when milliseconds are missing.
=#

function Base.parse(::Type{Interval{T}}, str::AbstractString) where T
    #=
    print(
        io,
        first(inclusivity(interval)) ? "[" : "(",
        first(interval),
        " .. ",
        last(interval),
        last(inclusivity(interval)) ? "]" : ")",
    )
    =#
    a, b = parse_inclusivity(str)
    f, l = _parse.(T, strip.(split(str[2:end-1], "..")))

    return Interval(f, l, a, b)
end

function Base.parse(::Type{<:AnchoredInterval{P, <:AbstractDateTime}}, str::AbstractString) where P
    # (2018-12-02 HE24-06:00]
    a, b = parse_inclusivity(str)
    dt, suffix = split(str[2:end-1], ' ')

    f = if startswith(suffix, "HE")
        HE
    elseif startswith(suffix, "HB")
        HB
    else
        throw(ArgumentError("Can only parse HE and HB anchored intervals"))
    end

    hr = parse(Int, suffix[3:4])

    anchor = if length(suffix) > 4
        ZonedDateTime(parse.(Int, split(dt, '-'))..., hr, FixedTimeZone(suffix[5:end]))
    else
        DateTime(parse.(Int, split(dt, '-'))..., hr)
    end

    return f(anchor, a, b)
end

_parse(::Type{T}, str::AbstractString) where T = parse(T, str)

function _parse(::Type{T}, str::AbstractString) where T <: DateTime
    if '.' in str
        parse(T, str)
    else
        parse(T, "$str.0")
    end
end

function _parse(::Type{T}, str::AbstractString) where T <: ZonedDateTime
    if '.' in str
        parse(T, str)
    else
        dt, t = split(str, 'T')
        tz_char = '+' in t ? '+' : '-'
        s = string(dt, 'T', join(split(t, tz_char), ".000$tz_char"))
        # println(s)
        parse(T, s)
    end
end

function parse_inclusivity(str::AbstractString)
    a = if str[1] == '['
        true
    elseif str[1] == '('
        false
    else
        throw(ArgumentError("Interval strings must start with '[' or '('."))
    end

    b = if str[end] == ']'
        true
    elseif str[end] == ')'
        false
    else
        throw(ArgumentError("Interval strings must end with ']' or ')'."))
    end

    return a, b
end
