# Jakub Musiał 268442

module KahanMachEps

function calculate_machine_epsilon(type::DataType)::type
    return type(3) * (type(4)  / type(3) - type(1)) - type(1)
end


function main()
    println("Machine epsilon (Kahan):\n")

    float_types = [Float16, Float32, Float64]
    for type in float_types
        println("$type:")

        kahan_macheps::type = calculate_machine_epsilon(type)
        builtin_macheps::type = eps(type)

        println("\tKahan     -> $kahan_macheps")
        println("\tBuiltin   -> $builtin_macheps")
        println("\tequal     = $(kahan_macheps == builtin_macheps)")
        println("\tequal abs = $(abs(kahan_macheps) == abs(builtin_macheps))")
        println()
    end
end

end # KahanMachEps


if abspath(PROGRAM_FILE) == @__FILE__
    KahanMachEps.main()
end
