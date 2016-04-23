using Base.Dates
import Base.Dates: value, coarserperiod

function condense(p::Period)
    last_type = typeof(p)
    last_value = value(p)

    current_type, multiplier = coarserperiod(last_type)
    v, r = divrem(value(p), multiplier)
    while r == 0
        last_type = current_type
        last_value = v

        current_type, multiplier = coarserperiod(last_type)
        v, r = divrem(v, multiplier)
    end

    return last_type(last_value)
end

function condense{P<:Period}(periods::Array{P})
    new_type, scalar = coarserperiod(eltype(periods))
    result = Array{new_type}(size(periods))

    for i in eachindex(periods)
        v, r = divrem(value(periods[i]), scalar)
        if r == 0
            result[i] = new_type(v)
        else
            return periods
        end
    end

    return condense(result)
end
