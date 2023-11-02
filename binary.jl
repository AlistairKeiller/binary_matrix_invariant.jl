function swap_columns(M, c1, c2, N)
    xor_mask = ((M >> ((c1 - 1) * N)) ⊻ (M >> ((c2 - 1) * N))) & ((1 << N) - 1)
    return M ⊻ ((xor_mask << ((c1 - 1) * N)) | (xor_mask << ((c2 - 1) * N)))
end

function swap_rows(M, r1, r2, N)
    xor_mask = ((M >> (r1 - 1)) ⊻ (M >> (r2 - 1))) & ((1 << (N * N) - 1) ÷ ((1 << N) - 1))
    return M ⊻ ((xor_mask << (r1 - 1)) | (xor_mask << (r2 - 1)))
end

function invert_column(M, c, N)
    return M ⊻ (((1 << N) - 1) << ((c - 1) * N))
end

function invert_row(M, r, N)
    return M ⊻ (((1 << (N * N) - 1) ÷ ((1 << N) - 1)) << (r - 1))
end

function look_for_new_M(new_M, queue, subgroups, subgroup_counter)
    if subgroups[new_M+1] == 0
        push!(queue, new_M)
        subgroups[new_M+1] = subgroup_counter
    end
end

function find_invariant_subgroups(N)
    subgroups = [0 for i in 1:2^(N^2)]
    subgroup_counter = 0

    while any(subgroups .== 0)
        subgroup_counter += 1
        seed = findfirst(subgroups .== 0) - 1
        subgroups[seed+1] = subgroup_counter
        queue = [seed]

        while !isempty(queue)
            M = pop!(queue)

            for i in 1:N
                look_for_new_M(invert_column(M, i, N), queue, subgroups, subgroup_counter)
                look_for_new_M(invert_row(M, i, N), queue, subgroups, subgroup_counter)

                for j in i+1:N
                    look_for_new_M(swap_columns(M, i, j, N), queue, subgroups, subgroup_counter)
                    look_for_new_M(swap_rows(M, i, j, N), queue, subgroups, subgroup_counter)
                end
            end
        end
    end
    return subgroups, subgroup_counter
end

function print_subgroups(N)
    subgroups, number_of_subgroups = find_invariant_subgroups(N)

    for subgroup in 1:number_of_subgroups
        in_subgroup = subgroups .== subgroup
        println("Subgroup:              ", subgroup)
        println("Subgroup member count: ", sum(in_subgroup))
        print("Representative matrix: ")
        representitive = findfirst(in_subgroup) - 1
        for r in 1:N
            for c in 1:N
                print(Int((representitive & (1 << ((r - 1) + (c - 1) * N))) > 0), " ")
            end
            println()
            print("                       ")
        end
        println()
        println()
    end
end

print_subgroups(5)
