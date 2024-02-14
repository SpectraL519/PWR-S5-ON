# Jakub Musiał 268442

module MachEps

function calculate_machine_epsilon(type::DataType)::type
    one = type(1)
    two = type(2)
    epsilon::type = one

    while epsilon + one > one
        epsilon /= two
    end

    return two * epsilon
end


function main()
    println("Machine epsilon:\n")

    float_types = [Float16, Float32, Float64]
    for type in float_types
        println("$type:")

        macheps::type = calculate_machine_epsilon(type)
        builtin_macheps::type = eps(type)

        println("\tCalculated -> $macheps")
        println("\tBuiltin    -> $builtin_macheps")
        println("\tBitstring  -> $(bitstring(macheps))\n")
    end
end

end # MachEps


if abspath(PROGRAM_FILE) == @__FILE__
    MachEps.main()
end
