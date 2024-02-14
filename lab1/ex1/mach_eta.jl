# Jakub Musiał 268442

module MachEta

function calculate_machine_eta(type::DataType)::type
    zero = type(0)
    two = type(2)

    eta_it::type = type(1) # helper variable to check correct value in an iteration
    eta::type = eta_it

    while eta_it > zero
        eta = eta_it
        eta_it /= two
    end

    return eta
end


function main()
    println("Machine eta:\n")

    float_types = [Float16, Float32, Float64]
    for type in float_types
        println("$type:")

        macheta::type = calculate_machine_eta(type)
        builtin_macheta::type = nextfloat(type(0))

        println("\tCalculated -> $macheta")
        println("\tBuiltin    -> $builtin_macheta")
        println("\tBitstring  -> $(bitstring(macheta))\n")
    end
end

end # MachEta


if abspath(PROGRAM_FILE) == @__FILE__
    MachEta.main()
end
