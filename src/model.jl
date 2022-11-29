include("model_activity.jl")
include("model_infection.jl")
include("model_disease.jl")

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
        # good approximation for these numbers
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
        encounter!(rand(inf), rand(susc), world.ief, pars)
    end
end

# only evolution if IEF for now
function virus!(virus, ief, pars)
    virus.age += 1

    if virus.age % pars.t_repr_cycle == 0
        virus.e_ief = expected_ief(virus.age, ief, pars) * virus.ief_0
    end
end

