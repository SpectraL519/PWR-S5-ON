# Jakub Musiał 268442

module DotProd

@enum SumMethod begin
    up_to
    down_to
    sorted_desc
    sorted_asc
end


module Detail

function sum_up_to(type::DataType, vector::Vector{})::type
    sum::type = type(0)
    for e in vector
        sum += e
    end
    return sum
end


function sum_down_to(type::DataType, vector::Vector{})::type
    sum::type = type(0)
    for e in reverse(vector)
        sum += e
    end
    return sum
end


function sum_sorted_desc(type::DataType, vector::Vector{})::type
    sorted_pos = sort(filter(e -> e >= 0, vector), rev = true)
    sorted_neg = sort(filter(e -> e < 0, vector))

    return sum_up_to(type, sorted_pos) + sum_up_to(type, sorted_neg)
end


function sum_sorted_asc(type::DataType, vector::Vector{})::type
    sorted_pos = sort(filter(e -> e >= 0, vector))
    sorted_neg = sort(filter(e -> e < 0, vector), rev = true)

    return sum_up_to(type, sorted_pos) + sum_up_to(type, sorted_neg)
end

end # Detail


function dot_product(
    type::DataType,
    X::Vector{},
    Y::Vector{},
    method::SumMethod
)::type
    @assert length(X) == length(Y) "X and Y must be of the same length"

    sum_funs = Dict(
        up_to       => Detail.sum_up_to,
        down_to     => Detail.sum_down_to,
        sorted_desc => Detail.sum_sorted_desc,
        sorted_asc  => Detail.sum_sorted_asc
    )

    # calculate the vector of products
    prod_vect = type[]
    for (x, y) in zip(X, Y)
        push!(prod_vect, type(x) * type(y))
    end

    return sum_funs[method](type, prod_vect)
end


function relative_error(value, expected)
    return abs(value - expected) / expected
end


function main()
    println("Dot product\n")

    X = [2.718281828, -3.141592654, 1.414213562, 0.577215664, 0.301029995]
    Y = [1486.2497, 878366.9879, -22.37492, 4773714.647, 0.000185049]

    true_dot_product = 1.00657107000000 * 10^(-11)

    println("Exact dot product value = $true_dot_product")

    for type in [Float32, Float64]
        println("$type:")
        for dot_method in instances(SumMethod)
            dot_method_str = String(Symbol(dot_method))
            product = dot_product(type, X, Y, dot_method)
            error = relative_error(product, true_dot_product)

            println("\t$(rpad(dot_method_str, 12)) -> $(rpad(product, 24)) : relative error = $error")
        end
        println()
    end
end

end # DotProd


if abspath(PROGRAM_FILE) == @__FILE__
    DotProd.main()
end
