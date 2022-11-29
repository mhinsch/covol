
function activity!(agent, world, day, minute, pars)
    # travel takes one tick for now
    if agent.activity == Activity.travel
        arrive!(agent, world, pars)
    else
        apply_schedule!(agent, world, pars, day, minute)
    end
end

