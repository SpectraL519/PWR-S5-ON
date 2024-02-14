# Jakub Musiał 268442

module LinEqSys

using DataFrames
using DataStructures
using PrettyTables
using LinearAlgebra

# include("../latex_table.jl")
include("utility/hilb.jl")
include("utility/matcond.jl")


# Gauss elimination method of solving a linear equation system
function solve_gauss(A::Matrix{Float64}, b::Vector{Float64})::Vector{Float64}
    return A \ b
end

# Inversion method of solving a linear equation system
function solve_inversion(A::Matrix{Float64}, b::Vector{Float64})::Vector{Float64}
    return inv(A) * b
end

function relative_error(x::Vector{Float64}, x_approx::Vector{Float64})::Float64
    return norm(x - x_approx) / norm(x)
end


function hilbert_matrix_experiment()
    println("Hilbert matrix experiment")

    data = OrderedDict(
        "n"               => Int[],
        "cond(A)"         => Float64[],
        "rank(A)"         => Int[],
        "gauss_error"     => Float64[],
        "inverison_error" => Float64[]
    )

    for n in 1:20
        A = hilb(n)
        x = ones(Float64, n)
        b = A * x

        x_gauss = solve_gauss(A, b)
        x_inversion = solve_inversion(A, b)

        gauss_error = relative_error(x, x_gauss)
        inversion_error = relative_error(x, x_inversion)

        push!(data["n"], n)
        push!(data["cond(A)"], cond(A))
        push!(data["rank(A)"], rank(A))
        push!(data["gauss_error"], gauss_error)
        push!(data["inverison_error"], inversion_error)
    end

    pretty_table(data, crop = :none, alignment = :l)
    # print_latex_table(data, "report/table/ex3_hilbert.txt")
end

function random_matrix_experiment()
    println("Random matrix experiment")

    N = [5, 10, 20]
    Cexp = [0, 1, 3, 7, 12, 16]

    data = OrderedDict(
        "n"               => Int[],
        "cond(A)"         => String[],
        "rank(A)"         => Int[],
        "gauss_error"     => Float64[],
        "inverison_error" => Float64[]
    )

    for n in N
        for c_exp in Cexp
            c = Float64(10 ^ c_exp)

            A = matcond(n, c)
            x = ones(Float64, n)
            b = A * x

            x_gauss = solve_gauss(A, b)
            x_inversion = solve_inversion(A, b)

            gauss_error = relative_error(x, x_gauss)
            inversion_error = relative_error(x, x_inversion)

            push!(data["n"], n)
            push!(data["cond(A)"], "10^{$c_exp}")
            push!(data["rank(A)"], rank(A))
            push!(data["gauss_error"], gauss_error)
            push!(data["inverison_error"], inversion_error)
        end
    end

    pretty_table(data, crop = :none, alignment = :l)
    # print_latex_table(data, "report/table/ex3_random.txt")
end

function main()
    hilbert_matrix_experiment()
    println()
    random_matrix_experiment()
end

end # LinEqSys


if abspath(PROGRAM_FILE) == @__FILE__
    LinEqSys.main()
end
