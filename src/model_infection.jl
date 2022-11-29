
function inf_rate(infectee, virus, pars)
    # tentative
    # TODO think about whether this makes sense
    pars.p_inf[Int(infectee.immune.status)] ^ (1/(infectee.risk*virus.e_ief))
end


function infect!(agent, virus, world, pars)
    agent.immune.status = IStatus.infected
    agent.virus.age = 0
    agent.virus.ief_0 = transmitted_ief(virus.age, world.ief, pars) * virus.ief_0
    agent.virus.e_ief = 1.0
end


# very simplistic model for now
function encounter!(inf, susc, place, world, pars)
    p_inf = inf_rate(susc, inf.virus, pars)

    if rand() < p_inf
        infect!(susc, inf.virus, world, pars)
    end
end


# done globally for now
# TODO take into account viral load
function infection!(place, world, pars)
    inf = Agent[]; susc = Agent[]
    for a in place.present
        if infectious(a)
            push!(inf, a)
        elseif susceptible(a)
            push!(susc, a)
        end
    end

    if isempty(inf) || isempty(susc)
        return
    end

    n_pairs = length(inf) * length(susc)

    # determine number of encounters
    if n_pairs > 15 && pars.p_encounter < 0.1
        # good approximation for these numbers
        n_enc = rand(Poisson(n_pairs * pars.p_encounter))
    else
        n_enc = 0
        for i in 1:n_pairs
            if rand() < pars.p_encounter
                n_enc += 1
            end
        end
    end

    for e in n_enc
        encounter!(rand(inf), rand(susc), place, world, pars)
    end
end
