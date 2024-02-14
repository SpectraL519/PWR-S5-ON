using DataStructures

function print_latex_table(dictionary::OrderedDict, filename::AbstractString)
    dict_keys = collect(keys(dictionary))
    dict_values = collect(values(dictionary))

    # Check if all vectors have the same length
    vector_lengths = Set(length.(dict_values))
    if length(vector_lengths) != 1
        throw(ArgumentError("All vectors must have the same length."))
    end

    n = first(vector_lengths)
    latexstring(x) = "\$$(replace(string(x), "_" => "\\_"))\$"

    open(filename, "w") do out
        println(out, "\\begin{table}[h!]")
        println(out, "\\centering")
        println(out, "\\begin{tabularx}{\\textwidth}{$(repeat("l ", length(dict_keys)))}")
        println(out, "\\hline")

        # Print header row with keys
        for key in dict_keys
            print(out, "$(latexstring(key))")
            if key != dict_keys[end]
                print(out, " & ")
            else
                println(out, " \\\\")
            end
        end

        println(out, "\\hline")

        # Print data rows
        for i in 1:n
            for j in 1:length(dict_keys)
                print(out, latexstring(dict_values[j][i]))
                if j != length(dict_keys)
                    print(out, " & ")
                else
                    println(out, " \\\\")
                end
            end
        end

        println(out, "\\hline")
        println(out, "\\end{tabularx}")
        println(out, "\\label{table:fill_label}")
        println(out, "\\caption{fill caption}")
        println(out, "\\end{table}")
    end
end
