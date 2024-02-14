# Jakub Musiał 268442

module EqFuncDiff

function f(x::Float64)::Float64
    return sqrt((x ^ 2) + 1) - 1
end


function g(x::Float64)::Float64
    return (x ^ 2) / (sqrt((x ^ 2) + 1) + 1)
end


function main()
    println("Equivalent function difference\n")

    open("report/ex6.csv", "w") do file
        write(file, "exponent,f(x),g(x)\n")

        max_exponent = 16
        for exp in 1:max_exponent
            x = Float64(8.0 ^ (-exp))
            println(rpad("x = 8^-$exp", 12), "f(x) = $(rpad(f(x), 24)) g(x) = $(g(x))")

            write(file, "$exp,$(f(x)),$(g(x))\n")
        end
    end
end

end # FuncDiff


if abspath(PROGRAM_FILE) == @__FILE__
    EqFuncDiff.main()
end
