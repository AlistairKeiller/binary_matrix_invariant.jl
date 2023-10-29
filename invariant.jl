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

function generate_binary_matrices(N)
    all_matrices = []
    for i in 0:2^(N^2)-1
        matrix = Matrix{Bool}(undef, N, N)
        mask = 1
        for r in 1:N
            for c in 1:N
                matrix[r, c] = (i & mask) > 0 ? true : false
                mask <<= 1
            end
        end
        push!(all_matrices, matrix)
    end
    return all_matrices
end

function find_invariant_subgroups(N)
    unchecked = Set(generate_binary_matrices(N))
    invariant_subgroups = Set{Matrix{Bool}}[]

    while !isempty(unchecked)
        seed = pop!(unchecked)
        subgroup = Set{Matrix{Bool}}([seed])
        queue = [seed]
        
        while !isempty(queue)
            current_matrix = popfirst!(queue)
            operations_results = apply_operations(current_matrix)
            
            for res in operations_results
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

find_invariant_subgroups(4)
