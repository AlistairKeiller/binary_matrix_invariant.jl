function apply_operations(M::Matrix{Bool})
    n, m = size(M)
    
    results = Vector{Matrix{Bool}}()
    
    for i in 1:n
        for j in i+1:n
            new_M = copy(M)
            new_M[i, :], new_M[j, :] = M[j, :], M[i, :]
            push!(results, new_M)
        end
    end
    
    for i in 1:m
        for j in i+1:m
            new_M = copy(M)
            new_M[:, i], new_M[:, j] = M[:, j], M[:, i]
            push!(results, new_M)
        end
    end
    
    for i in 1:n
        new_M = copy(M)
        new_M[i, :] = .!M[i, :]
        push!(results, new_M)
    end
    
    for i in 1:m
        new_M = copy(M)
        new_M[:, i] = .!M[:, i]
        push!(results, new_M)
    end
    
    return results
end

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

    while !isempty(unchecked)
        seed = pop!(unchecked)
        subgroup = Vector{Matrix{Bool}}([seed])
        queue = Vector{Matrix{Bool}}([seed])
        
        while !isempty(queue)
            current_matrix = popfirst!(queue)
            
            for res in apply_operations(current_matrix)
                if res in unchecked
                    push!(subgroup, res)
                    push!(queue, res)
                    delete!(unchecked, res)
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