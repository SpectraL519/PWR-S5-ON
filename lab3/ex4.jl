# Jakub Musiał 268442

module ex4

using DataFrames
using DataStructures
using PrettyTables

# include("../latex_table.jl")
include("solvers.jl")

using .Solvers


function main()
    println("f(x) = sin(x) - (0.5x) ^ 2\n")

    f = x -> sin(x) - (0.5 * x) ^ 2
    df = x -> cos(x) - (0.5 * x)

    delta = Float64(0.5 * 10.0 ^ -5)
    epsilon = Float64(0.5 * 10.0 ^ -5)
    maxit = 64

    bisection_result = Solvers.bisection(f, 1.5, 2.0, delta, epsilon)
    tangent_result = Solvers.tangent(f, df, 1.5, delta, epsilon, maxit)
    secant_result = Solvers.secant(f, 1.0, 2.0, delta, epsilon, maxit)

    data = OrderedDict(
        "method" => ["bisection", "tangent", "secant"],
        "r"      => [bisection_result.r, tangent_result.r, secant_result.r],
        "v"      => [bisection_result.v, tangent_result.v, secant_result.v],
        "it"     => [bisection_result.it, tangent_result.it, secant_result.it],
        "err"    => [bisection_result.err, tangent_result.err, secant_result.err]
    )

    pretty_table(data, crop = :none, alignment = :l)
    # print_latex_table(data, "report/table/ex4.txt")
end

end # ex4


if abspath(PROGRAM_FILE) == @__FILE__
    ex4.main()
end
