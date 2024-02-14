# Jakub Musiał 268442

module PopulationGrowth

using DataStructures
using PrettyTables

# include("../latex_table.jl")


struct ExperimentData{T}
    p_0::T
    r::T
end

function population_growth_model(type::DataType, p::AbstractFloat, r::AbstractFloat)::type
    return p + r * p * (type(1) - p)
end

function main()
    println("Population growth model")

    display_data = OrderedDict(
        "n"             => Int[],
        "Float32"       => Float32[],
        "Float32_trunc" => Float32[],
        "Float64"       => Float64[],
    )

    f32_data = ExperimentData{Float32}(0.01, 3)
    f64_data = ExperimentData{Float64}(0.01, 3)

    pn_f32 = f32_data.p_0
    pn_f32_trunc = f32_data.p_0
    pn_f64 = f64_data.p_0

    for n in 0:40
        if n == 10
            pn_f32_trunc = trunc(pn_f32_trunc, digits = 3, base = 10)
        end

        push!(display_data["n"], n)
        push!(display_data["Float32"], pn_f32)
        push!(display_data["Float32_trunc"], pn_f32_trunc)
        push!(display_data["Float64"], pn_f64)

        pn_f32 = population_growth_model(Float32, pn_f32, f32_data.r)
        pn_f32_trunc = population_growth_model(Float32, pn_f32_trunc, f32_data.r)
        pn_f64 = population_growth_model(Float64, pn_f64, f64_data.r)
    end

    pretty_table(display_data, crop = :none, alignment = :l)
    # print_latex_table(display_data, "report/table/ex5.txt")
end

end # PopulationGrowth


if abspath(PROGRAM_FILE) == @__FILE__
    PopulationGrowth.main()
end
