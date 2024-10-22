using Distributions
using PDMats:ScalMat


mutable struct Immunity
    phenotype :: Vector{Float64}
    age :: Int
    strength :: Float64
end

Immunity() = Immunity([], 0)


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
    push!(immune.immunities, Immunity(imm, 0, pars.imm_ini_str))
    nothing
end

# sigmoid-ish increase to maximum (at 5 days with default pars)
calc_imm_increase(str, pars) = pars.imm_increase * (1.0 - str) * (2*str)^2

# find best match for each infecting strain
# add new immunity if no sufficient match exists
function update_immune_system!(immune, viruses, pars)
    for imm in immune.immunities
        # keep track of age, so that we can delete unused ones
        imm.age += 1
    end
    
    for i in length(immune.immunities):-1:1
        if immune.immunities[i].age >= pars.max_imm_age
            remove_unsorted_at!(immune.immunities, i)
        end
    end
    
    matches = Float64[]
    for v in viruses
        best_i, best_match = find_best_match(immune, v, pars)
                
        push!(matches, best_match)
        if best_match < pars.min_match_req
            create_immunity!(immune, v, pars)
            strength = 0.0
        else
            # NOTE this only increases strength of best match, partial matches decay
            best_imm = immune.immunities[best_i]
            best_imm.age = 0
            best_imm.strength += pars.imm_decay + calc_imm_increase(best_imm.strength, pars)
            strength = best_imm.strength
        end
        matches[end] *= strength
    end
    
    for imm in immune.immunities
        # constant delta decay
        imm.strength = max(pars.imm_ini_str, imm.strength - pars.imm_decay)
    end
    matches
end
