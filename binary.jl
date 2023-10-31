function get_shift(r, c, N)
    return r - 1 + (c - 1) * N
end

function swap_columns(M, c1, c2, N)
    for r in 1:N
        bit1 = (M & (1 << get_shift(r, c1, N))) > 0
        bit2 = (M & (1 << get_shift(r, c2, N))) > 0

        xor_bit = bit1 ⊻ bit2

        M ⊻= xor_bit << get_shift(r, c1, N)
        M ⊻= xor_bit << get_shift(r, c2, N)
    end
    return M
end

function swap_rows(M, r1, r2, N)
    for c in 1:N
        bit1 = (M & (1 << get_shift(r1, c, N))) > 0
        bit2 = (M & (1 << get_shift(r2, c, N))) > 0

        xor_bit = bit1 ⊻ bit2

        M ⊻= xor_bit << get_shift(r1, c, N)
        M ⊻= xor_bit << get_shift(r2, c, N)
    end
    return M
end

function invert_column(M, c, N)
    for r in 1:N
        M ⊻= (1 << get_shift(r, c, N))
    end
    return M
end

function invert_row(M, r, N)
    for c in 1:N
        M ⊻= (1 << get_shift(r, c, N))
    end
    return M
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
                print(Int((representitive & (1 << get_shift(r, c, N))) > 0), " ")
            end
            println()
            print("                       ")
        end
        println()
        println()
    end
end

print_subgroups(4)
