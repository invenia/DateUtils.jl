# Math between a single `Period` and a range of `DateTime`/`ZonedDateTime`s already works.
# Allows arithmetic between a `DateTime`/`ZonedDateTime`/`Period` and a range of `Period`s.
# TODO: Should go in julia/base/dates/ranges.jl:
.+{T<:Period}(x::Union{TimeType,Period}, r::Range{T}) = (x + first(r)):step(r):(x + last(r))
.+{T<:Period}(r::Range{T}, x::Union{TimeType, Period}) = x .+ r
+{T<:Period}(r::Range{T}, x::Union{TimeType, Period}) = x .+ r
+{T<:Period}(x::Union{TimeType, Period}, r::Range{T}) = x .+ r
.-{T<:Period}(r::Range{T}, x::Union{TimeType,Period}) = (first(r) - x):step(r):(last(r) - x)
-{T<:Period}(r::Range{T}, x::Union{TimeType, Period}) = r .- x

# TODO: Docstrings. Indicate what :first and :last are for.
function (+)(x::Nullable{ZonedDateTime}, p::DatePeriod, occurrence::Symbol=:ambiguous)
    isnull(x) && return x
    zdt = get(x)
    dt, tz = localtime(zdt), timezone(zdt)
    possible = interpret(dt + p, tz, Local)

    num = length(possible)
    if num == 1
        return Nullable{ZonedDateTime}(first(possible))
    elseif num == 0
        return Nullable{ZonedDateTime}()
    else
        if occurrence == :first
            return Nullable{ZonedDateTime}(first(possible))
        elseif occurrence == :last
            return Nullable{ZonedDateTime}(last(possible))
        else
            return Nullable{ZonedDateTime}()
        end
    end
end

function (+)(x::Nullable{ZonedDateTime}, p::TimePeriod, occurrence::Symbol=:ambiguous)
    isnull(x) && return x
    zdt = get(x)
    return Nullable(ZonedDateTime(zdt.utc_datetime + p, timezone(zdt); from_utc=true))
end

(-)(x::Nullable{ZonedDateTime}, p::DatePeriod, occurrence::Symbol=:ambiguous) = +(x, -p, occurrence)
(-)(x::Nullable{ZonedDateTime}, p::TimePeriod, occurrence::Symbol=:ambiguous) = +(x, -p, occurrence)
