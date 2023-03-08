infected(agent) = agent.virus != NoVirus
#TODO virus levels, etc.
infectious(agent) = infected(agent)
infectivity(agent) = infectivity(agent.virus)
# TODO immune dynamics
sick(agent) = infected(agent)
susceptible(agent) = !infected(agent)


function initial_infect!(agent, pars, agens = nothing)
    if agens == nothing 
        agens = [Int16(rand(1:pars.max_antigen)) for i in 1:pars.n_antigens]
    end
   
    new_immunity!(agent.immune_system, agens, pars)
    agent.virus = AGIEFVirus(agens)
end


function p_infection(agent, pars)
    infected(agent) ? 0.0 : 1.0
end


function recover!(agent, pars)
    agent.virus = NoVirus
end


function disease!(agent, world, pars)
    reaction = update_immune_system!(agent.immune_system, agent.virus.antigens, pars)
    
    if reaction > pars.rec_threshold
        recover!(agent, pars)
    end
    
    if infected(agent)
        update_virus!(agent.virus, world.ief, pars)
    end
    
    nothing
end
