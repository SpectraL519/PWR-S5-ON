# Jakub Musiał 268442

module InvMul

function inverse_multiplication(x::Float64)::Float64
    return x * (Float64(1) / x)
end


function main()
    println("Smallest x for inverse multiplication\n")
    x = nextfloat(Float64(1))
    one = Float64(1)

    while x < 2.0 && inverse_multiplication(x) == one
        x = nextfloat(x)
    end

    println("smallest x : inverse_multiplication(x) != 1 -> $x")
end

end # InvMul


if abspath(PROGRAM_FILE) == @__FILE__
    InvMul.main()
end
