using IEFModel

mutable struct AGIEFVirus
    # time since infection
    age :: Int
    # inter host fitness of infecting strain
    ief_0 :: Float64
    # expected IEF (needed for inf prob)
    e_ief :: Float64
    antigens :: Antigens
end

AGIEFVirus(ag = []) = AGIEFVirus(0, 1.0, 1.0, ag)

const NoVirus = AGIEFVirus(0, 0, 0, [])

infectivity(virus) = virus.e_ief


function update_virus!(virus, ief, pars)
    virus.age += 1

    if virus.age % pars.t_repr_cycle == 0
        update_antigens!(virus.antigens, pars)
        virus.e_ief = expected_ief_factor(virus.age, ief, pars) * virus.ief_0
    end
end

function transmit(tr_virus, ief, pars)
    virus = AGIEFVirus(copy(tr_virus.antigens))
    virus.ief_0 = transmitted_ief_factor(tr_virus.age, ief, pars) * tr_virus.ief_0
    
    virus
end
