
function disease!(agent, world, pars)
    if agent.immune.status == IStatus.infected
        if rand() < pars.p_rec
            agent.immune.status = IStatus.recovered
        else
            update_virus!(agent.virus, world.ief, pars)
        end
    end
end

