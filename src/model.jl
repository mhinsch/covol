
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

    tp = Nowhere

    for t in tps, car in t.cars
        if length(car.present) < pars.car_cap
            tp = car
            break
        end
    end

    change_loc!(agent, tp)
end


function arrive!(agent, world, pars)
    @assert agent.activity == Activity.travel

    change_loc!(agent, agent.dest)
    agent.activity = agent.plan

    agent.dest = Nowhere
    agent.plan = Activity.none
end


function inf_rate(infectee, virus, pars)
    # tentative
    # TODO think about whether this makes sense
    pars.p_inf[Int(infectee.immune.status)] ^ (1/(infectee.risk*virus.e_ief))
end

# very simplistic model for now
function encounter!(inf, susc, place, world, pars)
    p_inf = inf_rate(susc, inf.virus, pars)

    if rand() < p_inf
        infect!(susc, inf.virus, world, pars)
    end
end

function infect!(agent, virus, world, pars)
    agent.immune.status = IStatus.infected
    agent.virus.age = 0
    agent.virus.ief = transmitted_ief(virus, world.ief, pars)
    agent.virus.e_ief = 1.0
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

# only evolution if IEF for now
function virus!(virus, ief, pars)
    virus.age += 1

    if virus.age % pars.t_repr_cycle == 0
        virus.e_ief = expected_ief(virus, ief, pars)
    end
end


function disease!(agent, world, pars)
    if agent.immune.status == IStatus.infected
        virus!(agent.virus, world.ief, pars)
        if rand() < pars.p_rec
            agent.immune.status = IStatus.recovered
        end
    end
end

