# Jakub Muiał 268442

include("blocksys.jl")
import .blocksys



function saveFileDiscriminator(readb::Bool, use_partial_pivot::Bool)::String
    return (readb ? "_b" : "") * (use_partial_pivot ? "_pivot" : "")
end

function runGaussianElimination(n::blocksys.int, readb::Bool, use_partial_pivot::Bool)
    test_data = "test/n" * "$n" * "/"
    println("reading data...")

    A = blocksys.readQCMatrix(test_data * "A.txt")
    expected_result = ones(blocksys.fl, A.n)

    b = (readb
        ? blocksys.readQCVector(test_data * "b.txt")
        : A * expected_result
    )
    @assert (size(A) == length(b)) "Matrix and rhs vector sizes do not match"
    println("success!")

    result = blocksys.solveEquationSystem(A, b, use_partial_pivot)
    error = blocksys.relativeError(result, expected_result)
    println("relative error = $error")

    # save results
    save_file = "x" * saveFileDiscriminator(readb, use_partial_pivot) * ".txt"
    blocksys.saveQCVector(result, test_data * save_file)
end

function runLUGaussianElimination(n::blocksys.int, readb::Bool, use_partial_pivot::Bool)
    test_data = "test/n" * "$n" * "/"
    println("reading data...")

    A = blocksys.readQCMatrix(test_data * "A.txt")
    expected_result = ones(blocksys.fl, A.n)

    b = (readb
        ? blocksys.readQCVector(test_data * "b.txt")
        : A * expected_result
    )
    @assert (size(A) == length(b)) "Matrix and rhs vector sizes do not match"
    println("success!")

    LU, πb = blocksys.getLUDecomposition(A, use_partial_pivot)
    result = blocksys.solveEquationSystemLU(LU, b, πb, use_partial_pivot)
    error = blocksys.relativeError(result, expected_result)
    println("relative error = $error")

    # save results
    save_file = "x" * saveFileDiscriminator(readb, use_partial_pivot) * ".txt"
    blocksys.saveQCVector(result, test_data * save_file)
end

function runTests()
    for n in [16, 10000, 50000, 100000, 300000, 500000]
        println("[n = $n]")
        for readb in [true, false]
            println("[readb = $readb]")
            for use_partial_pivot in [false, true]
                println("[use_partial_pivot = $use_partial_pivot]")
                runGaussianElimination(n, readb, use_partial_pivot)
                runLUGaussianElimination(n, readb, use_partial_pivot)
                println()
            end
            println()
        end
        println("\n")
    end
end



function benchmarkSaveFile(lu::Bool, use_partial_pivot::Bool, use_dict_matrix::Bool)::String
    dictriminator = (
        (lu ? "_lu" : "") *
        (use_partial_pivot ? "_pivot" : "") *
        (use_dict_matrix ? "_dict" : "")
    )
    return "report/data/benchmark" * dictriminator * ".csv"
end

function runGaussianEliminationBenchmark(
    n::blocksys.int, use_partial_pivot::Bool, use_dict_matrix::Bool
)
    test_data = "test/n" * "$n" * "/"
    println("reading data...")

    A = (use_dict_matrix
        ? blocksys.readQCDictMatrix(test_data * "A.txt")
        : blocksys.readQCMatrix(test_data * "A.txt")
    )
    expected_result = ones(blocksys.fl, A.n)
    b = A * expected_result
    @assert (size(A) == length(b)) "Matrix and rhs vector sizes do not match"
    println("success!")

    nexp = 10
    Σtime = blocksys.fl_zero
    for _ in 1:nexp
        Acpy = copy(A)
        bcpy = deepcopy(b)
        Σtime += @elapsed begin
            _ = blocksys.solveEquationSystem(Acpy, bcpy, use_partial_pivot)
        end
    end
    avg_time = Σtime / nexp

    error = blocksys.relativeError(
        blocksys.solveEquationSystem(A, b, use_partial_pivot), expected_result)
    println("relative error = $error")
    println("avg time = $avg_time")

    # save results
    open(benchmarkSaveFile(false, use_partial_pivot, use_dict_matrix), "a") do file
        println(file, "$n,$error,$avg_time")
    end
end

function runLUGaussianEliminationBenchmark(
    n::blocksys.int, use_partial_pivot::Bool, use_dict_matrix::Bool
)
    test_data = "test/n" * "$n" * "/"
    println("reading data...")

    A = (use_dict_matrix
        ? blocksys.readQCDictMatrix(test_data * "A.txt")
        : blocksys.readQCMatrix(test_data * "A.txt")
    )
    expected_result = ones(blocksys.fl, A.n)
    b = A * expected_result
    @assert (size(A) == length(b)) "Matrix and rhs vector sizes do not match"
    println("success!")

    Acpy = copy(A)
    Σtime = @elapsed begin
        LU, πb = blocksys.getLUDecomposition(Acpy, use_partial_pivot)
    end

    nexp = 10
    for _ in 1:nexp
        LUcpy = copy(LU)
        bcpy = deepcopy(b)
        Σtime += @elapsed begin
            _ = blocksys.solveEquationSystemLU(LUcpy, bcpy, πb, use_partial_pivot)
        end
    end
    avg_time = Σtime / nexp

    Acpy = copy(A)
    LU, πb = blocksys.getLUDecomposition(Acpy, use_partial_pivot)
    result = blocksys.solveEquationSystemLU(LU, b, πb, use_partial_pivot)
    error = blocksys.relativeError(result, expected_result)
    println("relative error = $error")
    println("avg time = $avg_time")

    # save results
    open(benchmarkSaveFile(true, use_partial_pivot, use_dict_matrix), "a") do file
        println(file, "$n,$error,$avg_time")
    end
end

function runBenchmarks()
    for use_partial_pivot in [false, true]
        for use_dict_matrix in [false, true]
            open(benchmarkSaveFile(false, use_partial_pivot, use_dict_matrix), "w") do file
                println(file, "n,\\delta,T_{avg}")
            end
            open(benchmarkSaveFile(true, use_partial_pivot, use_dict_matrix), "w") do file
                println(file, "n,\\delta,T_{avg}")
            end
        end
    end

    for n in [16, 10000, 50000, 100000, 300000, 500000]
        println("[n = $n]")
        for use_partial_pivot in [false, true]
            println("[use_partial_pivot = $use_partial_pivot]")
            for use_dict_matrix in [false, true]
                println("[use_dict_matrix = $use_dict_matrix]")
                runGaussianEliminationBenchmark(n, use_partial_pivot, use_dict_matrix)
                runLUGaussianEliminationBenchmark(n, use_partial_pivot, use_dict_matrix)
                println()
            end
            println()
        end
        println("\n")
    end
end



if abspath(PROGRAM_FILE) == @__FILE__
    n::blocksys.int = 16
    local run_tests = false
    local run_benchmarks = false

    for i in 1:length(ARGS)
        if ARGS[i] == "-t"
            run_tests = true
        end
        if ARGS[i] == "-b"
            run_benchmarks = true
        end
    end

    if run_tests
        println("running tests")
        runTests()
        println("\n\n")
    end
    if run_benchmarks
        println("running benchmarks")
        runBenchmarks()
        println("\n\n")
    end
end
