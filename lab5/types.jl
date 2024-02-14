# Jakub Muiał 268442

module types

export int, fl, fl_zero
int = Int64
fl = Float64
fl_zero = fl(0)



export AbstractQCMatrix, getQCColumnRange, getQCColumnRangePivot
abstract type AbstractQCMatrix end

function getQCColumnRange(qcm::AbstractQCMatrix, row::int)
    brow = (row - 1) ÷ qcm.l + 1
    return (
        max(1, (brow - 1) * qcm.l),
        # min((brow) * qcm.l + ((row - 1) % qcm.l) + 1, qcm.n)
        min((brow + 1) * qcm.l, qcm.n) # account for row swaps
    )
end

function getQCColumnRangePivot(qcm::AbstractQCMatrix, row::int)
    brow = (row - 1) ÷ qcm.l + 1
    return (
        max(1, (brow - 2) * qcm.l),
        min((brow + 1) * qcm.l, qcm.n)
    )
end

function Base.size(qcm::AbstractQCMatrix)
    return qcm.n
end

function Base.length(qcm::AbstractQCMatrix)
    return qcm.n
end

import Base: *
function *(qcm::AbstractQCMatrix, qcv::Vector{fl})::Vector{fl}
    n = size(qcm)
    @assert (n == length(qcv)) "Matrix and vector sizes do not match"

    result = zeros(fl, n)
    for k in 1:n
        col_range = getQCColumnRange(qcm, k)
        for i in col_range[1]:col_range[2]
            result[k] += qcm[k, i] * qcv[i]
        end
    end
    return result
end

function Base.show(io::IO, qcm::AbstractQCMatrix)
    println(io, "n = $(qcm.n), l = $(qcm.l)")
    for i in 1:qcm.n
        for j in 1:qcm.n
            if qcm[i, j] != 0
                print(io, "* ")
            else
                print(io, ". ")
            end
        end
        println(io)
    end
end



export QCMatrix
mutable struct QCMatrix <: AbstractQCMatrix
    n::int                  # matrix size [n x n]
    l::int                  # block size [l x l]
    A::Vector{Matrix{fl}}   # vector of A_k blocks - dense matrices
    B::Vector{Vector{fl}}   # vector of B_k blocks - only vectors of last column in a block
    C::Vector{Matrix{fl}}   # vector of C_k blocks - matrices with only diagonal being non-zero
                                                   # (not vectors because GE requires additional elements)
    # all get/set operations have constant O(1) cost

    function QCMatrix(n::int, l::int)
        @assert (n >= 4) "Invalid matrix size n - must be >= 4"
        @assert (l > 0) "Invalid submatrix size l - must be > 0"
        @assert (n % l == 0) "Invalid QCMatrix parameters: `n` not divisable by `l`"

        v = n ÷ l
        A = [zeros(fl, l, l) for _ in 1:v]
        B = [zeros(fl, l) for _ in 2:v]
        C = [zeros(fl, l, l) for _ in 1:v-1]
        new(n, l, A, B, C)
    end

    function QCMatrix(qcm::QCMatrix)
        new(qcm.n, qcm.l, deepcopy(qcm.A), deepcopy(qcm.B), deepcopy(qcm.C))
    end
end

Base.copy(qcm::QCMatrix) = QCMatrix(qcm)

function Base.getindex(qcm::QCMatrix, i::int, j::int)::fl
    # block indices
    brow = (i - 1) ÷ qcm.l + 1
    bcol = (j - 1) ÷ qcm.l + 1

    # within block indices
    row = (i - 1) % qcm.l + 1
    col = (j - 1) % qcm.l + 1

    if bcol == brow # Ak block
        return qcm.A[brow][row, col]
    end

    if bcol == brow - 1 && col == qcm.l # Bk block
        return qcm.B[brow - 1][row]
    end

    if bcol == brow + 1 # Ck block
        return qcm.C[brow][row, col]
    end

    return fl_zero
end

function Base.setindex!(qcm::QCMatrix, value::fl, i::int, j::int)
    # block indices
    brow = (i - 1) ÷ qcm.l + 1
    bcol = (j - 1) ÷ qcm.l + 1

    # within block indices
    row = (i - 1) % qcm.l + 1
    col = (j - 1) % qcm.l + 1

    if bcol == brow # Ak block
        qcm.A[brow][row, col] = value
        return
    end

    if bcol == brow - 1 && col == qcm.l # Bk block
        qcm.B[brow - 1][row] = value
        return
    end

    if bcol == brow + 1 # Ck block
        qcm.C[brow][row, col] = value
        return
    end
end



export QCDictMatrix
mutable struct QCDictMatrix <: AbstractQCMatrix
    n::int                          # matrix size [n x n]
    l::int                          # block size [l x l]
    M::Dict{Tuple{int, int}, fl}    # non-zero elements
                                    # all dictionary operations have an amortized cost of O(1)
                                    # and a worst case cost of O(n)

    function QCDictMatrix(n::int, l::int)
        @assert (n >= 4) "Invalid matrix size n - must be >= 4"
        @assert (l > 0) "Invalid submatrix size l - must be > 0"
        @assert (n % l == 0) "Invalid QCDictMatrix parameters: `n` not divisable by `l`"

        new(n, l, Dict{Tuple{Int64, Int64}, Float64}())
    end

    function QCDictMatrix(qcm::QCDictMatrix)
        new(qcm.n, qcm.l, copy(qcm.M))
    end
end

Base.copy(qcm::QCDictMatrix) = QCDictMatrix(qcm)

function Base.getindex(qcm::QCDictMatrix, i::int, j::int)::fl
    get(qcm.M, (i, j), fl_zero)
end

function Base.setindex!(qcm::QCDictMatrix, value::fl, i::int, j::int)
    if value == fl_zero
        delete!(qcm.M, (i, j))
        return
    end
    qcm.M[(i, j)] = value
end



# Utility: reading data
export readQCVector, saveQCVector, readQCMatrix, readQCDictMatrix

function readQCVector(file_path::String)::Vector{fl}
    open(file_path, "r") do file
        lines = readlines(file)

        n = parse(int, lines[1])
        b = [parse(fl, value) for value in lines[2:end]]
        @assert (length(b) == n) "Number of elements does not match given size"

        return b
    end
end

function saveQCVector(qcv::Vector{fl}, file_path::String)
    open(file_path, "w") do file
        for value in qcv
            println(file, value)
        end
    end
end

function parseQCMValue(str::String)
    i, j, value = split(str, " ")
    return parse(int, i), parse(int, j), parse(fl, value)
end

function readQCMatrix(file_path::String)::QCMatrix
    open(file_path, "r") do file
        lines = readlines(file)

        matrix_params = split(lines[1], " ")
        n = parse(int, matrix_params[1])
        l = parse(int, matrix_params[2])

        qcm = QCMatrix(n, l)
        values = [parseQCMValue(line) for line in lines[2:end]]
        for (i, j, value) in values
            qcm[i, j] = value
        end

        return qcm
    end
end

function readQCDictMatrix(file_path::String)::QCDictMatrix
    open(file_path, "r") do file
        lines = readlines(file)

        matrix_params = split(lines[1], " ")
        n = parse(int, matrix_params[1])
        l = parse(int, matrix_params[2])

        qcm = QCDictMatrix(n, l)
        values = [parseQCMValue(line) for line in lines[2:end]]
        for (i, j, value) in values
            qcm[i, j] = value
        end

        return qcm
    end
end

end # types
