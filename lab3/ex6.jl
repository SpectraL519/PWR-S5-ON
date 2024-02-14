# Jakub Musiał 268442

module ex6

using DataFrames
using DataStructures
using PrettyTables

# include("../latex_table.jl")
include("solvers.jl")

using .Solvers


function main()
    println("f1(x) = e^(1 - x) - 1\n")

    delta = Float64(10.0 ^ -5)
    epsilon = Float64(10.0 ^ -5)

    f1 = x -> exp(1.0 - x) - 1.0
    df1 = x -> -exp(1.0 - x)
    maxit = 256

    bisection_result_f1 = Solvers.bisection(f1, 0.0, 3.0, delta, epsilon)
    tangent_result_f1 = Solvers.tangent(f1, df1, exp(-1.0), delta, epsilon, maxit)
    secant_result_f1 = Solvers.secant(f1, 0.0, 2.0, delta, epsilon, maxit)

    data_f1 = OrderedDict(
        "method" => ["bisection", "tangent", "secant"],
        "r"      => [bisection_result_f1.r, tangent_result_f1.r, secant_result_f1.r],
        "v"      => [bisection_result_f1.v, tangent_result_f1.v, secant_result_f1.v],
        "it"     => [bisection_result_f1.it, tangent_result_f1.it, secant_result_f1.it],
        "err"    => [bisection_result_f1.err, tangent_result_f1.err, secant_result_f1.err]
    )

    pretty_table(data_f1, crop = :none, alignment = :l)
    # print_latex_table(data_f1, "report/table/ex6_f1.txt")


    println("\nf2(x) = x * e^(-x)\n")

    f2 = x -> x * exp(-x)
    df2 = x -> exp(-x) * (1.0 - x)

    bisection_result_f2 = Solvers.bisection(f2, -0.1, 2.0, delta, epsilon)
    tangent_result_f2 = Solvers.tangent(f2, df2, exp(-1.0), delta, epsilon, maxit)
    secant_result_f2 = Solvers.secant(f2, -1.0, 1.0, delta, epsilon, maxit)

    data_f2 = OrderedDict(
        "method" => ["bisection", "tangent", "secant"],
        "r"      => [bisection_result_f2.r, tangent_result_f2.r, secant_result_f2.r],
        "v"      => [bisection_result_f2.v, tangent_result_f2.v, secant_result_f2.v],
        "it"     => [bisection_result_f2.it, tangent_result_f2.it, secant_result_f2.it],
        "err"    => [bisection_result_f2.err, tangent_result_f2.err, secant_result_f2.err]
    )

    pretty_table(data_f2, crop = :none, alignment = :l)
    # print_latex_table(data_f2, "report/table/ex6_f2.txt")


    println("\n\nNewton method test")

    data_newton_f1 = OrderedDict(
        "x0"  => Float64[],
        "r"   => Float64[],
        "v"   => Float64[],
        "it"  => Int[],
        "err" => Solvers.Error[]
    )

    data_newton_f2 = OrderedDict(
        "x0"  => Float64[],
        "r"   => Float64[],
        "v"   => Float64[],
        "it"  => Int[],
        "err" => Solvers.Error[]
    )

    for k in 1:20
        x0 = Float64(k)

        newton_test_f1 = Solvers.tangent(f1, df1, x0, delta, epsilon, maxit)
        push!(data_newton_f1["x0"], x0)
        push!(data_newton_f1["r"], newton_test_f1.r)
        push!(data_newton_f1["v"], newton_test_f1.v)
        push!(data_newton_f1["it"], newton_test_f1.it)
        push!(data_newton_f1["err"], newton_test_f1.err)

        newton_test_f2 = Solvers.tangent(f2, df2, x0, delta, epsilon, maxit)
        push!(data_newton_f2["x0"], x0)
        push!(data_newton_f2["r"], newton_test_f2.r)
        push!(data_newton_f2["v"], newton_test_f2.v)
        push!(data_newton_f2["it"], newton_test_f2.it)
        push!(data_newton_f2["err"], newton_test_f2.err)
    end

    pretty_table(data_newton_f1, crop = :none, alignment = :l)
    # print_latex_table(data_newton_f1, "report/table/ex6_newton_f1.txt")

    pretty_table(data_newton_f2, crop = :none, alignment = :l)
    # print_latex_table(data_newton_f2, "report/table/ex6_newton_f2.txt")
end

end # ex6


if abspath(PROGRAM_FILE) == @__FILE__
    ex6.main()
end
