function matrix_to_binary(M::Matrix{Bool})
    sum = 0
    for (i, bit) in enumerate(M)
        sum += bit << (i-1)
    end
    return sum
end

function binary_to_matrix(b, N)
    matrix = Matrix{Bool}(undef, N, N)
    @inbounds for i in eachindex(matrix)
        matrix[i] = (b & 1 << (i - 1)) > 0
    end
    return matrix
end

function generate_binary_matrices(N)
    return Set(binary_to_matrix(i, N) for i in 0:2^(N^2)-1)
end

function find_invariant_subgroups(N)
    unchecked = generate_binary_matrices(N)
    invariant_subgroups = Vector{Vector{Matrix{Bool}}}()

    function process_matrix(current_matrix, unchecked, subgroup, queue, action)
        action(current_matrix)
        if current_matrix in unchecked
            copy_matrix = copy(current_matrix)
            push!(subgroup, copy_matrix)
            push!(queue, copy_matrix)
            delete!(unchecked, copy_matrix)
        end
        action(current_matrix)
    end

    function toggle_row!(matrix, i)
        @inbounds for k in 1:N
            matrix[i, k] = !matrix[i, k]
        end
    end

    function toggle_column!(matrix, i)
        @inbounds for k in 1:N
            matrix[k, i] = !matrix[k, i]
        end
    end

    function swap_rows!(matrix, i, j)
        @inbounds for k in 1:N
            matrix[i, k], matrix[j, k] = matrix[j, k], matrix[i, k]
        end
    end

    function swap_columns!(matrix, i, j)
        @inbounds for k in 1:N
            matrix[k, i], matrix[k, j] = matrix[k, j], matrix[k, i]
        end
    end

    while !isempty(unchecked)
        seed = pop!(unchecked)
        subgroup, queue = [seed], [seed]

        while !isempty(queue)
            current_matrix = pop!(queue)

            for i in 1:N
                process_matrix(current_matrix, unchecked, subgroup, queue, matrix -> toggle_row!(matrix, i))
                process_matrix(current_matrix, unchecked, subgroup, queue, matrix -> toggle_column!(matrix, i))

                for j in i+1:N
                    process_matrix(current_matrix, unchecked, subgroup, queue, matrix -> swap_rows!(matrix, i, j))
                    process_matrix(current_matrix, unchecked, subgroup, queue, matrix -> swap_columns!(matrix, i, j))
                end
            end
        end

        push!(invariant_subgroups, subgroup)
    end

    return invariant_subgroups
end

function pretty_print_matrix(M)
    for i in 1:size(M, 1)
        for j in 1:size(M, 2)
            print(Int(M[i, j]), " ")
        end
        println()
		print("                    ")
    end
end

function print_subgroups(N)
    subgroups = find_invariant_subgroups(N)
    for (i, subgroup) in enumerate(subgroups)
        println("Subgroup:           ", i)
        println("Number of matrices: ", length(subgroup))
        print("Minimum matrix:     ")
        pretty_print_matrix(binary_to_matrix(minimum(matrix_to_binary, subgroup), N))
        println("\n" ^ 2)
    end
end

print_subgroups(4)