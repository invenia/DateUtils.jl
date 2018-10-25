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
