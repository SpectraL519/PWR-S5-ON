# Jakub Musiał 268442

module FuncPlot

using LinearAlgebra
using Plots


function f(x::Float64)::Float64
    return exp(x) * log(Float64(1) + exp(-x))
end


function main(save::Union{String, Nothing})
    println("f(x) = e^x * ln(1 + e^(-x)) plot\n")

    X::Vector{Float64} = LinRange(0.0, 50.0, 1000)
    Y = map(f, X)

    function_plot = plot(
        X, Y,
        label="f(x)", xlabel="x", ylabel="f(x) = e^x * ln(1 + e^(-x))"
    )

    if save === nothing
        display(function_plot)
    else
        Plots.png(function_plot, save)
    end
end

end # FuncPlot


if abspath(PROGRAM_FILE) == @__FILE__
    save = nothing
    if length(ARGS) == 1
        save = ARGS[1]
    end

    FuncPlot.main(save)
end
