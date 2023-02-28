using IEFModel


function inf_rate(infectee, virus, mitigation, pars)
    inf_exp = infectee.risk * virus.e_ief * (1.0 - mitigation)
    1 - (1 - pars.p_inf_base * pars.p_inf[Int(infectee.immune.status)]) ^ inf_exp
end


function infect!(agent, virus, ief, pars, iefpars)
    agent.immune.status = IStatus.infected
    agent.virus.age = 0
    agent.virus.ief_0 = transmitted_ief_factor(virus.age, ief, iefpars) * virus.ief_0
    agent.virus.e_ief = 1.0
end


# very simplistic model for now
function encounter!(inf, susc, ief, mitigation, pars, iefpars)
    p_inf = inf_rate(susc, inf.virus, mitigation, pars)

    if rand() < p_inf
        infect!(susc, inf.virus, ief, pars, iefpars)
        return true
    end
    false
end


