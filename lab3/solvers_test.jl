# Jakub Musiał 268442

module SolversTest

using Test
    
include("solvers.jl")
using .Solvers


test_functions::Vector{Pair{Function, Function}} = [
    Pair(x -> 0.25 * (x ^ 2) - 1, x -> 2 * x),
    Pair(x -> sin(x) + cos(x), x -> cos(x) - sin(x)),
    Pair(x -> exp(-x) - 2, x -> -1.0 * exp(-x))
]

expected_roots::Vector{Float64} = [2.0, 3.0 * pi / 4.0, -1.0 * log(2)]

delta::Float64 = 10.0 ^ (-5)
epsilon::Float64 = 10.0 ^ (-5)


@testset "bisection" begin
    A::Vector{Float64} = [0.0, 0.0, -5.0 * log(2)]
    B::Vector{Float64} = [30.0, 4.0, 3.0 * log(2)]

    for (i, (func, _)) in enumerate(test_functions)
        result::Solvers.Result = Solvers.bisection(func, A[i], B[i], delta, epsilon)
        if (result.err != Solvers.no_error)
            println("(ERROR) $(result.err)")
        end

        @test isapprox(result.r, expected_roots[i], atol=epsilon * 10.0)
    end
end

println()

@testset "tangent" begin
    X0::Vector{Float64} = [4.0, 2.25, -2.1 * log(2)]
    maxit = 64

    for (i, (func, deriv)) in enumerate(test_functions)
        result::Solvers.Result = Solvers.tangent(func, deriv, X0[i], delta, epsilon, maxit)
        if (result.err != Solvers.no_error)
            println("(ERROR) $(result.err)")
        end

        @test isapprox(result.r, expected_roots[i], atol=epsilon * 10.0)
    end
end

println()

@testset "secant" begin
    X0::Vector{Float64} = [0.0, pi / 4.0, -2.0 * log(2)]
    X1::Vector{Float64} = [4.0, 5.0 * pi / 4.0, 0.0]
    maxit = 32

    for (i, (func, _)) in enumerate(test_functions)
        result::Solvers.Result = Solvers.secant(func, X0[i], X1[i], delta, epsilon, maxit)
        if (result.err != Solvers.no_error)
            println("(ERROR) $(result.err)")
        end

        @test isapprox(result.r, expected_roots[i], atol=epsilon)
    end
end

end # SolversTest