function matrix_to_binary(M::Matrix{Bool})
    place = 1
	result = 0
	for v in M
		result += v * place
		place <<= 1
	end
	return result
end

function binary_to_matrix(b, N)
	matrix = Matrix{Bool}(undef, N, N)
	mask = 1
	for v in eachindex(matrix)
		matrix[v] = (b & mask) == 0 ? false : true
		mask <<= 1
	end
	return matrix
end

function generate_binary_matrices(N)
    all_matrices = Set{Matrix{Bool}}()
    for i in 0:2^(N^2)-1
        push!(all_matrices, binary_to_matrix(i, N))
    end
    return all_matrices
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

function print_subgroups(N)
    for (i, subgroup) in enumerate(find_invariant_subgroups(N))
		println("Subgroup:           $i")
		println("Number of matrices: $(length(subgroup))")
		display(binary_to_matrix(minimum(matrix_to_binary, subgroup), N))
        println()
    end
end

print_subgroups(4)