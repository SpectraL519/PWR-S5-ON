# Jakub Muiał 268442

module blocksys

using LinearAlgebra

include("types.jl")
using .types



# Exerice 1.a
function gaussianElimination(
    A::AbstractQCMatrix, b::Vector{fl}
)::Tuple{AbstractQCMatrix, Vector{fl}}
    for k in 1:A.n-1 # O(n)
        maxrow = min(k + A.l - (k % A.l), A.n)
        maxcol = min(k + A.l, A.n)
        for i in k+1:maxrow # O(l) * O(matrixop)
            l_ik = A[i, k] / A[k, k]
            for j in k+1:maxcol # O(l) * O(matrixop)
                A[i, j] -= l_ik * A[k, j]
            end
            b[i] -= l_ik * b[k]
        end
    end
    return A, b
end

# Exerice 1.b
function gaussianPartialPivotElimination(
    A::AbstractQCMatrix, b::Vector{fl}
)::Tuple{AbstractQCMatrix, Vector{fl}}
    for k in 1:A.n-1
        maxrow = min(k + A.l - (k % A.l), A.n) # O(l)

        # partial pivot - O(l) * O(matrixop)
        max_value_row = k + argmax([abs(A[i, k]) for i in k:maxrow]) - 1
        if max_value_row != k
            # swap rows in matrix A and vector b - O(l) * O(matrixop)
            col_range = getQCColumnRangePivot(A, max_value_row)
            for i in col_range[1]:col_range[2]
                A[k, i], A[max_value_row, i] = A[max_value_row, i], A[k, i]
            end
            b[k], b[max_value_row] = b[max_value_row], b[k]
        end

        maxcol = getQCColumnRangePivot(A, k)[2]
        for i in k+1:maxrow # O(l) * O(matrixop)
            l_ik = A[i, k] / A[k, k]
            for j in k:maxcol # O(l) * O(matrixop)
                A[i, j] -= l_ik * A[k, j]
            end
            b[i] -= l_ik * b[k]
        end
    end

    return A, b
end

# Exerice 1
export solveEquationSystem
function solveEquationSystem(
    A::AbstractQCMatrix, b::Vector{fl}, use_partial_pivot::Bool = false
)::Vector{fl}
    gA, gb = (use_partial_pivot
        ? gaussianPartialPivotElimination(A, b)
        : gaussianElimination(A, b)
    )
    # println(gA)

    x = zeros(fl, A.n)

    for k in A.n:-1:1
        Σ = fl_zero
        maxcol = (use_partial_pivot
            ? getQCColumnRangePivot(A, k)[2]
            : min(k + A.l, A.n)
        )
        for i in k+1:maxcol # O(l) * O(matrixop)
            Σ += gA[k, i] * x[i]
        end
        x[k] = (gb[k] - Σ) / gA[k, k]
    end

    return x

end



# Exerice 2.a
function gaussianEliminationLU(A::AbstractQCMatrix)::AbstractQCMatrix
    for k in 1:A.n-1 # O(n)
        maxrow = min(k + A.l - (k % A.l), A.n)
        maxcol = min(k + A.l, A.n)
        for i in k+1:maxrow # O(l) * O(matrixop)
            l_ik = A[i, k] / A[k, k]
            A[i, k] = l_ik
            for j in k+1:maxcol # O(l) * O(matrixop)
                A[i, j] -= l_ik * A[k, j]
            end
        end
    end
    return A
end

# Exerice 2.b
function gaussianPartialPivotEliminationLU(A::AbstractQCMatrix)::Tuple{AbstractQCMatrix, Vector{int}}
    πb = [i for i in 1:A.n] # perumation of vector b equivalent to the A matrix permutation

    for k in 1:A.n-1
        maxrow = min(k + 2 * A.l - (k % A.l), A.n) # O(l)

        max_value_row = k + argmax([abs(A[i, k]) for i in k:maxrow]) - 1
        if max_value_row != k
            πb[k], πb[max_value_row] = πb[max_value_row], πb[k]
            col_range = getQCColumnRangePivot(A, max_value_row)
            for i in col_range[1]:col_range[2]
                A[k, i], A[max_value_row, i] = A[max_value_row, i], A[k, i]
            end
        end

        maxcol = getQCColumnRangePivot(A, k)[2]
        for i in k+1:maxrow
            l_ik = A[i, k] / A[k, k]
            for j in k:maxcol
                A[i, j] -= l_ik * A[k, j]
            end
            A[i, k] = l_ik
        end
    end

    return A, πb
end

# Exercise 2
export getLUDecomposition
function getLUDecomposition(
    A::AbstractQCMatrix, use_partial_pivot::Bool = false
)::Tuple{AbstractQCMatrix, Vector{int}}
    return (use_partial_pivot
        ? gaussianPartialPivotEliminationLU(A)
        : (gaussianEliminationLU(A), [i for i in 1:A.n])
    )
end

# Exericise 3
export solveEquationSystemLU
function solveEquationSystemLU(
    A::AbstractQCMatrix, b::Vector{fl}, πb::Vector{int}, use_partial_pivot::Bool
)::Vector{fl}
    # solve Ly = b
    y = zeros(fl, A.n)
    for k in 1:A.n
        mincol = getQCColumnRange(A, k)[1]
        Σ = fl_zero
        for i in mincol:(k-1)
            Σ += A[k, i] * y[i]
        end
        y[k] = b[πb[k]] - Σ
    end

    # solve Ux = y
    x = zeros(fl, A.n)
    for k in A.n:-1:1
        maxcol = (use_partial_pivot
            ? getQCColumnRangePivot(A, k)[2]
            : min(k + A.l, A.n)
        )
        Σ = fl_zero
        for i in k+1:maxcol
            Σ += A[k, i] * x[i]
        end
        x[k] = (y[k] - Σ) / A[k, k]
    end

    return x
end



export relativeError
function relativeError(actual::Vector{fl}, expected::Vector{fl})::fl
    return abs(norm(actual - expected)) / norm(expected)
end

end # blocksys
