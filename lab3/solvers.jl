# Jakub Muiał 268442

module Solvers

import Base.show

@enum Error::Int begin
    no_error
    error_1
    error_2
end

struct Result
    r::Float64
    v::Float64
    it::Int
    err::Error
end

function Base.show(io::IO, result::Result)
    print(io, "r = $(result.r), v = $(result.v), it = $(result.it), err = $(result.err)")
end


function bisection(
    f::Function, a::Float64, b::Float64, delta::Float64, epsilon::Float64
)::Result
    a, b = minmax(a, b)

    f_a = f(a)
    f_b = f(b)

    if sign(f_a) == sign(f_b)
        return Result(0, 0, 0, error_1)
    end

    two64 = Float64(2)
    distance = b - a
    it = 0
    
    while true
        it += 1

        distance /= 2.0
        mid::Float64 = a + distance
        f_mid::Float64 = f(mid)

        if abs(distance) < delta || abs(f_mid) < epsilon
            return Result(mid, f_mid, it, no_error)
        end

        if sign(f_a) == sign(f_mid)
            a = mid
            f_a = f_mid
        else
            b = mid
            f_b = f_mid
        end
    end
end


function tangent(
    f, df, x0::Float64, delta::Float64, epsilon::Float64, maxit::Int
)::Result
    v = f(x0)

    if abs(v) < epsilon
        return Result(x0, v, 0, no_error)
    end
    
    mach_eps = eps(Float64)
    err::Error = no_error

    for it in 1:maxit
        df_x0 = df(x0)

        if abs(df_x0) < mach_eps
            return Result(0, 0, it, error_2)
        end

        x1 = x0 - (v / df_x0)
        v = f(x1)

        if abs(x1 - x0) < delta || abs(v) < epsilon
            return Result(x1, v, it, err)
        end

        x0 = x1
    end

    return Result(0, 0, maxit, error_1)
end


function secant(
    f, x0::Float64, x1::Float64, delta::Float64, epsilon::Float64, maxit::Int
)::Result
    f_x0 = f(x0)
    f_x1 = f(x1)

    for it in 1:maxit
        if abs(f_x0) > abs(f_x1)
            x0, x1 = x1, x0
            f_x0, f_x1 = f_x1, f_x0
        end

        s = (x1 - x0) / (f_x1 - f_x0)
        x1 = x0
        f_x1 = f_x0
        x0 = x0 - (f_x0 * s)
        f_x0 = f(x0)

        if abs(x1 - x0) < delta || abs(f_x1) < epsilon
            return Result(x0, f_x0, it, no_error)
        end
    end

    return Result(0, 0, maxit, error_1)
end

end # Solvers