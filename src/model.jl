
function activity!(agent, world, day, minute, pars)
    # travel takes one tick for now
    if agent.activity == Activity.travel
        arrive!(agent, world, pars)
    else
        apply_schedule!(agent, world, pars, day, minute)
    end
end

function get_transports(world, p1, p2, act, pars)
    t1 = world.t_cache[p1.pos.x, p1.pos.y]
    t2 = world.t_cache[p2.pos.x, p2.pos.y]

    intersect(t1, t2)
end


function go_to_work!(agent, world, pars)
    @assert agent.activity == Activity.home

    travel!(agent, agent.work, Activity.working, world, pars)
end

function go_home!(agent, world, pars)
    @assert agent.activity == Activity.working

    travel!(agent, agent.home, Activity.home, world, pars)
end

function travel!(agent, dest, activity, world, pars)
    agent.activity = Activity.travel
    agent.plan = activity
    agent.dest = dest

    tps = get_transports(world, agent.loc, dest, activity, pars)

    # placeholder
    # TODO assign cars
    tp = isempty(tps) ? Nowhere : tps[1].cars[1]
    change_loc!(agent, tp)
end


function arrive!(agent, world, pars)
    @assert agent.activity == Activity.travel

    change_loc!(agent, agent.dest)
    agent.activity = agent.plan

    agent.dest = Nowhere
    agent.plan = Activity.none
end


function calc_inf_rate(place, pars)
    n_inf = count(place.present) do a
        a.immune.status == IStatus.infected
    end

    # probability to encounter at least one infected individual and
    # be exposed to the virus
    # TODO account for multiple encounters?
    1 - (1 - pars.p_encounter * pars.p_expose)^n_inf
end

# very simplistic model for now
function expose!(agent, pars)
    p_inf = pars.p_inf[Int(agent.immune.status)] ^ agent.risk
end


# done globally for now
# TODO take into account viral load
# TODO [strains] pairwise when strains are implemented
function infection!(place, pars)
    # currently step-wise
    prob = calc_inf_rate(place, pars)
    
    for agent in place.present
        if agent.immune.status != IStatus.infected && rand() < prob
            expose!(agent, pars)
        end
    end
end

