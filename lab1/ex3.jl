# Jakub Musiał 268442

module FloatRange

struct Float64Range
    start::Float64
    stop::Float64
end


function check_range_spacing(range::Float64Range, delta::Float64)
    println("Range begin:")
    value::Float64 = range.start
    true_value::Float64 = value
    for _ in 1:3
        value += delta
        true_value = nextfloat(true_value)
        equal = (value == true_value) ? "eqaul" : "not equal"
        println("\t$(rpad(value, 20)) -> $(bitstring(value)) (nextfloat: $equal)")
    end

    println("Range end:")
    value = range.stop
    true_value = value
    for _ in 1:3
        value -= delta
        true_value = prevfloat(true_value)
        equal = (value == true_value) ? "eqaul" : "not equal"
        println("\t$(rpad(value, 20)) -> $(bitstring(value)) (prevfloat: $equal)")
    end
end


function main()
    println("Arrangement of numbers in an interval\n")

    ranges::Vector{Float64Range} = [
        Float64Range(0.5, 1.0),
        Float64Range(1.0, 2.0),
        Float64Range(2.0, 4.0)
    ]
    delta_exponents::Vector{Int} = [-53, -52, -51]

    for (range, exp) in zip(ranges, delta_exponents)
        println("Range = [$(range.start), $(range.stop)], delta = 2^($exp):")
        check_range_spacing(range, 2.0 ^ exp)
        println("\n")
    end
end

end # FloatRange


if abspath(PROGRAM_FILE) == @__FILE__
    FloatRange.main()
end
