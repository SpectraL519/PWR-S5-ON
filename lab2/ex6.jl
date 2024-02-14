# Jakub Musiał 268442

module RecursiveEquation

using CSV
using DataFrames
using DataStructures
using PrettyTables

# include("../latex_table.jl")


struct ExperimentData
    c::Float64
    x_0::Float64
end

function f(x::Float64, c::Float64)::Float64
    return x ^ 2 + c
end

function get_key(c::Float64, x_0::Float64)::String
    return "c = $c, x_0 = $x_0"
end

function main()
    println("Recursive equation: x_{n+1} = x_n ^ 2 + c\n")

    n = 40
    experiments_data::Vector{ExperimentData} = [
        ExperimentData(-2, 1),
        ExperimentData(-2, 2),
        ExperimentData(-2, 1.99999999999999),
        ExperimentData(-1, 1),
        ExperimentData(-1, -1),
        ExperimentData(-1, 0.75),
        ExperimentData(-1, 0.25)
    ]

    data_dict = OrderedDict{String, Vector{Float64}}()
    for data in experiments_data
        data_dict[get_key(data.c, data.x_0)] = Float64[]
    end

    display_data = merge(OrderedDict("n" => Int[]), data_dict)
    for n in 0:40
        push!(display_data["n"], n)
    end

    for (i, data) in enumerate(experiments_data)
        x = data.x_0
        key = get_key(data.c, data.x_0)

        for n in 0:40
            push!(display_data[key], x)
            x = f(x, data.c)
        end
    end

    pretty_table(display_data, crop = :none, alignment = :l)
    # print_latex_table(display_data, "report/table/ex6.txt")

    CSV.write("report/ex6.csv", DataFrame(display_data))
end

end # RecursiveEquation


if abspath(PROGRAM_FILE) == @__FILE__
    RecursiveEquation.main()
end
