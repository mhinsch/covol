infected(agent) = length(agent.viruses) > 0
infectious(agent) = infected(agent)
infectivity(agent) = 1.0
sick(agent) = agent.health < 1.0
susceptible(agent) = !infected(agent)


function initial_infect!(agent, pars, pheno = nothing)
    if pheno == nothing 
        pheno = rand(pars.n_antigens)
    end
   
    agent.viruses = [Virus(pheno)]
end


function prob_heal(agent, match, pars)
    sigmoid((1.0-match), pars.heal_steep, pars.heal_offs) * pars.max_heal_prob * agent.immune_strength
end


function heal!(agent, i, pars)
    remove_unsorted_at!(agent.viruses, i)
    nothing
end

# TODO: effect of competition or cross-over
function prob_mutate(match, nviruses, pars)
    sigmoid((1.0-match), pars.mut_steep, pars.mut_offs) * pars.max_prob_mut
end

# TODO: should this *modify* or *add*?
function mutate_virus!(agent, idx, pars)
    agent.viruses[idx] = mutate_virus(agent.viruses[idx], pars.mutate_dist)
    nothing
end


function update_disease!(agent, world, pars)
    matches = update_immune_system!(agent.immune, agent.viruses, pars)
    
    if ! infected(agent)
        return nothing
    end
    
    # iterate in reverse in case viruses have to be removed
    for i in length(agent.viruses):-1:1
        p_heal = prob_heal(agent, matches[i], pars)
        if rand() < p_heal
            heal!(agent, i, pars)
            continue
        end
        p_mutate = prob_mutate(matches[i], length(agent.viruses), pars)
        if rand() < p_mutate
            mutate_virus!(agent, i, pars)
        end
    end
    
    nothing
end
