using Base.Dates
import Base.Dates: value, coarserperiod

function condense(p::P) where P <: Period
    last_type = P
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
