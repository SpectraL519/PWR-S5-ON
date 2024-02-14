# Jakub Muiał 268442

include("blocksys.jl")
import .blocksys



function run(n::blocksys.int, readb::Bool, use_partial_pivot::Bool, save_result::Bool)
    test_data = "test/n" * "$n" * "/"
    println("reading data...")

    A = blocksys.readQCMatrix(test_data * "A.txt")
    expected_result = ones(blocksys.fl, A.n)

    b = (readb
        ? blocksys.readQCVector(test_data * "b.txt")
        : A * expected_result
    )

    println("success!")
    if A.n < 20
        println(A)
    end

    LU, πb = blocksys.getLUDecomposition(A, use_partial_pivot)
    result = blocksys.solveEquationSystemLU(LU, b, πb, use_partial_pivot)
    error = blocksys.relativeError(result, expected_result)

    println("\nresult:")
    if A.n <= 20
        # println(A)
        println("x = $result\n")
    end
    println("relative error = $error")

    # save result
    if !save_result
        return
    end

    save_file_discriminator = (readb ? "_b" : "") * (use_partial_pivot ? "_pivot" : "")

    save_file = "x" * (readb ? "_b" : "") * (use_partial_pivot ? "_pivot" : "") * ".txt"
    blocksys.saveQCVector(result, test_data * save_file)

    save_file = "report/data/error" * save_file_discriminator * ".txt"
    open(save_file, "a") do file
        print(file, "$n,$error")
    end
end



if abspath(PROGRAM_FILE) == @__FILE__
    n::blocksys.int = 16
    local readb = false
    local use_partial_pivot = false
    local save_result = false

    if length(ARGS) >= 1
        n = parse(blocksys.int, ARGS[1])
    end
    for i in 2:length(ARGS)
        if ARGS[i] == "-b"
            readb = true
        end
        if ARGS[i] == "-p"
            use_partial_pivot = true
        end
        if ARGS[i] == "-s"
            save_result = true
        end
    end

    run(n, readb, use_partial_pivot, save_result)
end
