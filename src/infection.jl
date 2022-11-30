using IEFModel

function inf_rate(infectee, virus, pars)
    # tentative
    # TODO think about whether this makes sense
    pars.p_inf[Int(infectee.immune.status)] ^ (1/(infectee.risk*virus.e_ief))
end


function infect!(agent, virus, ief, pars, iefpars)
    agent.immune.status = IStatus.infected
    agent.virus.age = 0
    agent.virus.ief_0 = transmitted_ief_factor(virus.age, ief, iefpars) * virus.ief_0
    agent.virus.e_ief = 1.0
end


# very simplistic model for now
function encounter!(inf, susc, ief, pars, iefpars)
    p_inf = inf_rate(susc, inf.virus, pars)

    if rand() < p_inf
        infect!(susc, inf.virus, ief, pars, iefpars)
    end
end


