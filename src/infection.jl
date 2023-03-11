using IEFModel


function inf_rate(infectee, virus, mitigation, pars)
    inf_exp = infectee.risk + virus.e_ief * (1.0 - mitigation)
    1 - (1 - pars.p_inf_base * p_infection(infectee, pars)) ^ inf_exp
end


function infect!(agent, virus, ief, pars)
    agent.virus = transmit(virus, ief, pars)
end


# very simplistic model for now
function encounter!(inf, susc, ief, mitigation, pars)
    p_inf = inf_rate(susc, inf.virus, mitigation, pars)

    if rand() < p_inf
        infect!(susc, inf.virus, ief, pars)
        return true
    end
    false
end


