using IEFModel

# TODO replace with proper model
mutable struct Virus
    # time steps since infection
    age :: Int
    # inter host fitness of infecting strain
    ief_0 :: Float64
    # expected IEF (needed for inf prob)
    e_ief :: Float64
end

Virus() = Virus(0, 0.0, 0.0)


# only evolution if IEF for now
function update_virus!(virus, ief, pars)
    virus.age += 1

    if virus.age % pars.t_repr_cycle == 0
        virus.e_ief = expected_ief_factor(virus.age, ief, pars) * virus.ief_0
    end
end


function transmit(tr_virus, ief, pars)
    virus = Virus()
    virus.ief_0 = transmitted_ief_factor(tr_virus.age, ief, pars) * tr_virus.ief_0
    virus.e_ief = virus.ief_0
    
    virus
end
