function get_transports(world, p1, p2, act, pars)
    t1 = world.t_cache[p1.pos.x, p1.pos.y]
    t2 = world.t_cache[p2.pos.x, p2.pos.y]

    intersect(t1, t2)
end

cov_wariness(agent, caution) = (agent.cov_experience * (1.0 - agent.recklessness)) ^ (1/caution)

function decide_home2leisure(agent, world, pars, t)
    if rand() < cov_wariness(agent, pars.caution_leisure)
        agent.activity = Activity.stay_home
        return
    end
    if t < 11*60 && rand() < (t - 7*60) / 150
        go_to_work!(agent, world, pars)
    end
    nothing
end
    

function decide_home2work(agent, world, pars, t)
    if rand() < cov_wariness(agent, pars.caution_work)
        agent.activity = Activity.stay_home
        return
    end
    if t < 11*60 && rand() < (t - 7*60) / 150
        go_to_work!(agent, world, pars)
    end
    nothing
end

function decide_work2home(agent, world, pars, t)
    if rand() < cov_wariness(agent, pars.caution_work) ||
            rand() < (t - 16.5*60) / 90
        go_home!(agent, world, pars, Activity.stay_home)
    end
    nothing
end


function decide_public_transport(agent, pars)
    ! (rand() < cov_wariness(agent, pars.caution_pub_transp))
end


function go_to_work!(agent, world, pars)
    @assert agent.activity == Activity.home

    travel!(agent, agent.work, Activity.working, world, pars)
end

function go_home!(agent, world, pars, plan = Activity.home)
    @assert agent.activity == Activity.working

    travel!(agent, agent.home, plan, world, pars)
end

"start agent travel"
function travel!(agent, dest, activity, world, pars)
    agent.activity = Activity.travel
    agent.plan = activity
    agent.dest = dest
    
    tp = Nowhere
    
    if decide_public_transport(agent, pars)
        tps = get_transports(world, agent.loc, dest, activity, pars)

        for t in tps, car in t.cars
            if length(car.present) < pars.car_cap
                tp = car
                break
            end
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

# TODO diminishing returns for higher numbers friends/family
function covid_experience!(agent, world, pars)
    delta = - agent.cov_experience * pars.exp_decay 
    
    if sick(agent)
        delta += (1.0 - agent.cov_experience) * pars.exp_self_weight
    end
    
    ps = count(sick, agent.family) / length(agent.family)
    delta += (1.0 - agent.cov_experience) * pars.exp_family_weight * ps

    ps = count(sick, agent.friends) / length(agent.friends)
    delta += (1.0 - agent.cov_experience) * pars.exp_friends_weight * ps
    
    agent.cov_experience = max(min(agent.cov_experience + delta, 1.0), 0.0)
end

# done globally for now
# TODO take into account viral load
function infection!(place, world, pars, iefpars)
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
        if encounter!(rand(inf), rand(susc), world.ief, pars, iefpars)
            place.n_infections += 1
        end
    end
    nothing
end

