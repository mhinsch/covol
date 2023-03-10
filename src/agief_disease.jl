infected(agent) = agent.virus != NoVirus
#TODO virus levels, etc.
infectious(agent) = infected(agent)
infectivity(agent) = infectivity(agent.virus)
sick(agent) = agent.health < 1.0
susceptible(agent) = !infected(agent)


function initial_infect!(agent, pars, agens = nothing)
    if agens == nothing 
        agens = [Int16(rand(1:pars.max_antigen)) for i in 1:pars.n_antigens]
    end
   
    agent.virus = AGIEFVirus(agens)
end


function p_infection(agent, pars)
    infected(agent) ? 0.0 : 1.0
end


function symptomatic!(agent, pars)
    agent.health = rand()
end


function recover!(agent, pars)
    agent.virus = NoVirus
    agent.health = 1.0
end


function disease!(agent, world, pars)
    reaction = update_immune_system!(agent.immune_system, agent.virus.antigens, pars)
    
    if infected(agent)
        if reaction > pars.rec_threshold || rand() < pars.p_rec
            recover!(agent, pars)
            return
        elseif !sick(agent) && rand() < pars.p_sympt
            symptomatic!(agent, pars)
        end
        update_virus!(agent.virus, world.ief, pars)
    end
    
    nothing
end
