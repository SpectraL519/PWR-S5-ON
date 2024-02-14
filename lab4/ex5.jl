# Jakub Musiał 268442

module ex5

include("interpolation.jl")

using .Interpolation


const FuncData = Tuple{Function, Float64, Float64}


function main()
    println("generating interpolation plots")

    functions::Vector{FuncData} = [
        (x -> exp(x), 0., 1.),
        (x -> x ^ 2 * sin(x), -1., 1.)
    ]

    N::Vector{Int} = [5, 10, 15]

    for (i, (func, a, b)) in enumerate(functions)
        println("function: $i")
        for n in N
            save_path = "report/img/ex5_f$(i)_n$n.png"
            Interpolation.plot_interpolated_function(func, a, b, n, save_path)
        end
    end
end

end # ex5


if abspath(PROGRAM_FILE) == @__FILE__
    ex5.main()
end
