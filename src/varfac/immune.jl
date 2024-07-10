using Distributions
using PDMats:ScalMat


struct Immunity
    phenotype :: Vector{Float64}
end

Immunity() = Immunity([])


struct Immune
    immunities :: Vector{Immunity}
end

Immune() = Immune([])


function match_distance(virus, immune, pars)
    # euclidean distance
    dist = sqrt(sum((virus.phenotype .- immune.phenotype) .^ 2))
    # response curve 1 = closest match
    sigmoid(dist, pars.match_steep, pars.match_offs)
end


function find_best_match(immune, v, pars)
    best_i = 0
    best_match = 0.0
    for (i,m) in enumerate(immune.immunities)
        match = match_distance(v, m, pars)
        if match > best_match
            best_match = match
            best_i = i
        end
    end
    
    best_i, best_match
end


function create_immunity!(immune, virus, pars)
    imm = virus.phenotype .+ rand(MvNormal(ScalMat(length(virus.phenotype), pars.immune_dist)))
    push!(immune.immunities, Immunity(imm))
    nothing
end


# find best match for each infecting strain
# add new immunity if no sufficient match exists
function update_immune_system!(immune, viruses, pars)
    matches = Float64[]
    for v in viruses
        best_i, best_match = find_best_match(immune, v, pars)
                
        push!(matches, best_match)
        if best_match < pars.min_match_req
            create_immunity!(immune, v, pars)
        end
    end
    
    matches
end
