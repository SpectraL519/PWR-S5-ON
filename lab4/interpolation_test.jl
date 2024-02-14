# Jakub Musiał 268442

module InterpolationTest

using Test

include("interpolation.jl")
using .Interpolation


function vector_comp(v1::Vector{Float64}, v2::Vector{Float64}, epsilon::Float64)
    return all(abs.(v1 - v2) .<= epsilon)
end


epsilon = 1e-10


const TestData = Vector{Tuple{
    Function,        # tested function
    Vector{Float64}, # input data
    Vector{Float64}  # expected result
}}


@testset "differential_quotients" begin
    test_data::TestData = [
        (x -> 2. * x + 5., [1., 3.], [7., 2.]),
        (x -> x ^ 2. - 3., [1., 3., 5.], [-2., 4., 1.]),
        (x -> x ^ 3. - 3. * x ^ 2. + 3. * x + 5., [1., 3., 5., 7.], [6., 4., 6., 1.])
    ]

    for (func, x, expected_fx) in test_data
        f = map(func, x)
        fx = Interpolation.differential_quotients(x, f)
        @test vector_comp(fx, expected_fx, epsilon)
    end
end

println()

@testset "newton_value" begin
    test_data::TestData = [
        (x -> 2. * x + 5., [1., 3.], []),
        (x -> x ^ 2. - 3., [1., 3., 5.], []),
        (x -> x ^ 3. - 3. * x ^ 2. + 3 * x + 5., [1., 3., 5., 7.], [])
    ]

    for (func, x, _) in test_data
        f = map(func, x)
        fx = Interpolation.differential_quotients(x, f)
        newton = t -> Interpolation.newton_value(x, fx, t)
        newton_result = map(newton, x)
        @test vector_comp(newton_result, f, epsilon)
    end
end

println()

@testset "natural_coefficients" begin
    test_data::TestData = [
        (x -> 2. * x + 5., [1., 3.], [5., 2.]),
        (x -> x ^ 2. - 3., [1., 3., 5.], [-3., 0., 1.]),
        (x -> x ^ 3. - 3. * x ^ 2. + 3. * x + 5., [1., 3., 5., 7.], [5., 3., -3., 1.])
    ]

    for (func, x, expected_natural) in test_data
        f = map(func, x)
        fx = Interpolation.differential_quotients(x, f)
        natural = Interpolation.natural_coefficients(x, fx)
        @test vector_comp(natural, expected_natural, epsilon)
    end
end

println()

function plot_interpolated_function_test()
    println("generating test plot: sqrt(x)")

    # test data
    func = x -> sqrt(x)
    a, b = 0., 2.
    n = 5

    save_path = "report/img/test.png"
    Interpolation.plot_interpolated_function(func, a, b, n, save_path)
end

end # InterpolationTest


if abspath(PROGRAM_FILE) == @__FILE__
    InterpolationTest.plot_interpolated_function_test()
end
