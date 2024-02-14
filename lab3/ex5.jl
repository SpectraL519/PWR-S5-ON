# Jakub Musiał 268442

module ex5

include("solvers.jl")

using .Solvers


function main()
    println("f(x) = 3x - e^x\n")

    f = x -> 3.0 * x - exp(x)

    delta = Float64(10.0 ^ -4)
    epsilon = Float64(10.0 ^ -4)

    result_1 = Solvers.bisection(f, 0.0, 1.0, delta, epsilon)
    result_2 = Solvers.bisection(f, 1.0, 2.0, delta, epsilon)

    println("Bisection method result:")
    println(result_1)
    println(result_2)
end

end # ex5


if abspath(PROGRAM_FILE) == @__FILE__
    ex5.main()
end
