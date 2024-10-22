infected(agent) = length(agent.viruses) > 0
infectious(agent) = infected(agent)
infectivity(agent) = 1.0
sick(agent, pars) = agent.health < pars.sick_threshold
too_sick(agent, pars) = agent.health < pars.too_sick_threshold
susceptible(agent) = true #!infected(agent)


function initial_infect!(agent, pars, pheno = nothing)
    if pheno == nothing 
        pheno = rand(pars.n_antigens)
    end
   
    agent.viruses = [Virus(pheno)]
end


function prob_heal(agent, match, pars)
    sigmoid((1.0-match), pars.heal_steep, pars.heal_offs) * pars.max_heal_prob 
end


function heal!(agent, i, pars)
    remove_unsorted_at!(agent.viruses, i)
    nothing
end

# TODO: effect of competition or cross-over
function prob_mutate(match, nviruses, pars)
    prob_mut_sel = sigmoid((1.0-match), pars.mut_steep, pars.mut_offs) * pars.max_prob_mut
    1.0 - (1.0 - prob_mut_sel) * (1.0 - pars.base_prob_mut)
end

# TODO: should this *modify* or *add*?
function mutate_virus!(agent, idx, pars)
    #agent.viruses[idx] = mutate_virus(agent.viruses[idx], pars.mutate_dist)
    mutate_virus2!(agent.viruses[idx], rand(Poisson(pars.mut_rate)), pars.mutate_dist)
    nothing
end


function update_disease!(agent, world, pars)
    matches = update_immune_system!(agent.immune, agent.viruses, pars)
    
    agent.health += min(1.0 - agent.health, pars.speed_recov)
    
    if ! infected(agent)
        agent.inf_duration = 0
        return nothing
    end
    
    agent.inf_duration += 1
    min_p_heal = 1.0
    
    # iterate in reverse in case viruses have to be removed
    for i in length(agent.viruses):-1:1
        p_heal = prob_heal(agent, matches[i] * (1.0-agent.risk), pars)
        # find virus with worst effect
        min_p_heal = min(min_p_heal, p_heal)
        if rand() < p_heal
            heal!(agent, i, pars)
            continue
        end
        p_mutate = prob_mutate(matches[i] * (1.0-agent.risk), length(agent.viruses), pars)
        if rand() < p_mutate
            mutate_virus!(agent, i, pars)
        end
    end
    
    if (agent.health > min_p_heal^pars.health_shape)
        agent.health -= pars.speed_sick
    end
    
    nothing
end
