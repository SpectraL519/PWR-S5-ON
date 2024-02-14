# Jakub Musiał 268442

module WilkinsonPoly

using Polynomials
using DataStructures
using PrettyTables

# include("../latex_table.jl")


function main()
    println("Wilkinson polynomial")

    wilkinson_num_roots::Int = 20
    wilkinson_roots::Vector{Float64} = [Float64(n) for n in 1:wilkinson_num_roots]
    wilkinson_coefficients::Vector{Float64} = [
        1, -210.0, 20615.0, -1256850.0,
        53327946.0, -1672280820.0, 40171771630.0,
        -756111184500.0, 11310276995381.0, -135585182899530.0,
        1307535010540395.0, -10142299865511450.0, 63030812099294896.0,
        -311333643161390640.0, 1206647803780373360.0, -3599979517947607200.0,
        8037811822645051776.0, -12870931245150988800.0, 13803759753640704000.0,
        -8752948036761600000.0, 2432902008176640000.0
    ]

    wilkinson_poly_calculated::Polynomial{Float64} = Polynomial(reverse(wilkinson_coefficients))
    wilkinson_poly_from_roots::Polynomial{Float64} = fromroots(wilkinson_roots)

    wilkinson_roots_calculated::Vector{Float64} = roots(wilkinson_poly_calculated)

    wilkinson_data = OrderedDict(
        "k"            => Int[],
        "z_k"          => Float64[],
        "abs(P(z_k))"  => Float64[],
        "abs(p(z_k))"  => Float64[],
        "abs(z_k - k)" => Float64[]
    )

    for k in 1:wilkinson_num_roots
        root_k = wilkinson_roots_calculated[k]

        push!(wilkinson_data["k"], k)
        push!(wilkinson_data["z_k"], root_k)
        push!(wilkinson_data["abs(P(z_k))"], abs(wilkinson_poly_calculated(root_k)))
        push!(wilkinson_data["abs(p(z_k))"], abs(wilkinson_poly_from_roots(root_k)))
        push!(wilkinson_data["abs(z_k - k)"], abs(root_k - k))
    end

    pretty_table(wilkinson_data, crop = :none, alignment = :l)
    # print_latex_table(wilkinson_data, "report/table/ex4_wilkinson.txt")

    println()

    println("Distorted wilkinson polynomial")

    distorted_coefficients::Vector{Float64} = wilkinson_coefficients
    distorted_coefficients[2] = Float64(-210) - Float64(2^(-23))

    distorted_poly_calculated = Polynomial(reverse(distorted_coefficients))
    distorted_roots_calculated = roots(distorted_poly_calculated)

    distorted_data = OrderedDict(
        "k"            => Int[],
        "z_k"          => ComplexF64[],
        "abs(P(z_k))"  => Float64[],
        "abs(z_k - k)" => Float64[]
    )

    for k in 1:wilkinson_num_roots
        root_k = distorted_roots_calculated[k]

        push!(distorted_data["k"], k)
        push!(distorted_data["z_k"], root_k)
        push!(distorted_data["abs(P(z_k))"], abs(distorted_poly_calculated(root_k)))
        push!(distorted_data["abs(z_k - k)"], abs(root_k - k))
    end

    pretty_table(distorted_data, crop = :none, alignment = :l)
    # print_latex_table(distorted_data, "report/table/ex4_distorted.txt")
end

end # WilkinsonPoly


if abspath(PROGRAM_FILE) == @__FILE__
    WilkinsonPoly.main()
end
