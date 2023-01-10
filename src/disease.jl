
function disease!(agent, world, pars, iefpars)
    if agent.immune.status == IStatus.infected
        update_virus!(agent.virus, world.ief, iefpars)
        if rand() < pars.p_rec
            agent.immune.status = IStatus.recovered
        end
    end
end
