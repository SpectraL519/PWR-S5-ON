# Jakub Muiał 268442

module Interpolation

using Plots


function differential_quotients(x::Vector{Float64}, f::Vector{Float64})::Vector{Float64}
    n = length(x)
    fx::Vector{Float64} = deepcopy(f)

    for i in 2:n
        for j in n:-1:i
            fx[j] = (fx[j] - fx[j-1]) / (x[j] - x[j-i+1])
        end
    end

    return fx
end

function newton_value(x::Vector{Float64}, fx::Vector{Float64}, t::Float64)::Float64
    n = length(x)
    nt::Float64 = fx[n]

    for i in n-1:-1:1
        nt = fx[i] + (t - x[i]) * nt
    end

    return nt
end

function natural_coefficients(x::Vector{Float64}, fx::Vector{Float64})::Vector{Float64}
    n = length(x)
    a::Vector{Float64} = zeros(n)
    a[n] = fx[n]

    for i in n-1:-1:1
        a[i] = fx[i] - x[i] * a[i+1]
        for j in i+1:n-1
            a[j] = a[j] - x[i] * a[j+1]
        end
    end

    return a
end

function plot_interpolated_function(
    func::Function, a::Float64, b::Float64, n::Int,
    save::Union{String, Nothing} = nothing
)
    a, b = minmax(a, b)

    # calculate interpolated function values and differential quotients
    x = Vector{Float64}(undef, n + 1)
    step = (b - a) / n
    for i = 1:n+1
        x[i] = a + (i - 1) * step
    end

    f = map(func, x)
    fx = differential_quotients(x, f)

    # calculate interpolation polynomial function values
    n_plot = 100

    x_plot = Vector{Float64}(undef, n_plot)
    step_plot = (b - a) / (n_plot - 1)
    for i = 1:n_plot
        x_plot[i] = a + (i - 1) * step_plot
    end

    f_plot = map(func, x_plot)

    newton = t -> Interpolation.newton_value(x, fx, t)
    f_poly = map(newton, x_plot)

    # Plot the results
    interpolation_plot = plot(
        plot_title = "Polynomial interpolation [n = $n]",
        x_plot, [f_plot f_poly],
        label = ["Interpolated function" "Interpolation polynomial"],
        color = ["black" "green"],
        linewidth = [8 3],
        legend_position = :topleft,
        size=(800, 600)
    )

    if save === nothing
        display(interpolation_plot)
    else
        Plots.png(interpolation_plot, save)
    end
end

end # Interpolation
