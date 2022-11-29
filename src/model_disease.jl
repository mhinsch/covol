
function disease!(agent, world, pars)
    if agent.immune.status == IStatus.infected
        virus!(agent.virus, world.ief, pars)
        if rand() < pars.p_rec
            agent.immune.status = IStatus.recovered
        end
    end
end

