# Jakub Musiał 268442

module MaxFloat

function calculate_max_float(type::DataType)::type
    max_float::type = type(1)
    two::type = type(2)

    while !isinf(max_float * two)
        max_float *= two
    end

    # add the remaining value (smaller than the power of 2 obtained in the previous loop)
    remaining_value::type = max_float / two
    while remaining_value != 0
        if !isinf(max_float + remaining_value)
            max_float += remaining_value
        end
        remaining_value /= two
    end

    return max_float
end


function main()
    println("Maximum float value:\n")

    float_types = [Float16, Float32, Float64]
    for type in float_types
        println("$type:")

        max_float::type = calculate_max_float(type)
        builtin_max_float::type = floatmax(type)

        println("\tCalculated -> $max_float")
        println("\tBuiltin    -> $builtin_max_float")
        println("\tBitstring  -> $(bitstring(max_float))\n")
    end
end

end # MaxFloat


if abspath(PROGRAM_FILE) == @__FILE__
    MaxFloat.main()
end
