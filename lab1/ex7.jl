# Jakub Musiał 268442

module DerivAppr

import Pkg
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("DataStructures")
Pkg.add("PrettyTables")

using CSV
using DataFrames
using DataStructures
using PrettyTables


function f(x::Float64)::Float64
    return sin(x) + cos(3 * x)
end


function f_derivative(x0::Float64)::Float64
    return cos(x0) - 3 * sin(3 * x0)
end


function f_derivative_approx(x0::Float64, h::Float64)::Float64
    return (f(x0 + h) - f(x0)) / h
end


function absolute_error(value::Float64, expected::Float64)::Float64
    return abs(value - expected)
end


function main()
    println("Derivative approximation\n")

    data = Dict(
        "n"        => Int[],
        "df"           => Float64[],
        "df_approx"    => Float64[],
        "approx_error" => Float64[]
    )

    x0 = Float64(1)
    max_exponent = 54
    for exp in 1:max_exponent
        h = Float64(2.0 ^ (-exp))

        df::Float64 = f_derivative(x0)
        df_approx::Float64 = f_derivative_approx(x0, h)

        push!(data["n"], exp)
        push!(data["df"], df)
        push!(data["df_approx"], df_approx)
        push!(data["approx_error"], absolute_error(df, df_approx))
    end

    display_data = OrderedDict(
        "h"              => ["2 ^ -$exp" for exp in data["n"]],
        "f'(x0)"         => data["df"],
        "approx(f'(x0))" => data["df_approx"],
        "approx error"   => data["approx_error"]
    )
    pretty_table(display_data, crop = :none, alignment = :l)

    CSV.write("report/ex7.csv", DataFrame(data))
end

end # DerivAppr


if abspath(PROGRAM_FILE) == @__FILE__
    DerivAppr.main()
end
