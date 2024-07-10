
function inf_rate(infectee, virus, mitigation, pars)
    _, match = find_best_match(infectee.immune, virus, pars)
    inf_exp = infectee.risk + (1.0 - match) * (1.0 - mitigation)
    1 - (1 - pars.p_inf_base #=* p_infection(infectee, pars)=#) ^ inf_exp
end


# very simplistic model for now
function encounter!(inf, susc, mitigation, pars)
    inf_virus = rand(inf.viruses)
    p_inf = inf_rate(susc, inf_virus, mitigation, pars)

    if rand() < p_inf
        infect!(susc, inf_virus, pars)
        return true
    end
    false
end


