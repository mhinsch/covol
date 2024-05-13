macro static_var(init)
  var = gensym()
  Base.eval(__module__, :(const $var = $init))
  quote
    global $var
    $var
  end |> esc
end


function get_transports(world, p1, p2, act, pars)
    t1 = world.t_cache[p1.pos.x, p1.pos.y]
    t2 = world.t_cache[p2.pos.x, p2.pos.y]
   
    inters = @static_var Transport[]
    empty!(inters)
    
    for t in t1
        if t in t2
            push!(inters, t)
        end
    end
    
    inters
end

cov_wariness(agent, caution) = (agent.cov_experience * (1.0 - agent.recklessness)) ^ (1/caution)


function decide_home2leisure(agent, world, pars, t)
    if (sick(agent) && world.isolation && rand() > agent.obstinacy) ||
        rand() < cov_wariness(agent, pars.caution_leisure) ||
        (world.lockdown && rand() > agent.obstinacy)
        agent.activity = Activity.stay_home
        return
    end
    
    # wait half an hour, then leave at some point within 5 hours
    agent.t_next_act = t + rand(1:300) + 30
    agent.activity = Activity.prepare_leisure
    nothing
end

function check_go_to_leisure(agent, world, pars, t)
    if t >= agent.t_next_act
        go_to_leisure!(agent, world, pars, t)
    end
    nothing
end
    
function decide_leisure2home(agent, world, pars, t)
    if t >= agent.t_next_act
        go_home!(agent, world, pars, Activity.stay_home)
    end
    nothing    
end

function decide_home2work(agent, world, pars, t)
    if (sick(agent) && world.isolation && rand() > agent.obstinacy) ||
        rand() < cov_wariness(agent, pars.caution_work) ||
        (world.lockdown && rand() > agent.obstinacy)
        agent.activity = Activity.stay_home
        return
    end
    
    agent.t_next_act = t + rand(1:120) + 60
    agent.activity = Activity.prepare_work
    nothing
end

function check_go_to_work(agent, world, pars, t)
    if t >= agent.t_next_act
        go_to_work!(agent, world, pars)
    end
    nothing
end

function decide_work2home(agent, world, pars, t)
    if  rand() < (t - 16.5*60) / 90
        go_home!(agent, world, pars, Activity.stay_home)
    end
    nothing
end


function decide_public_transport(agent, pars)
    ! (rand() < cov_wariness(agent, pars.caution_pub_transp))
end


function go_to_work!(agent, world, pars)
    @assert agent.activity == Activity.prepare_work

    travel!(agent, agent.work, Activity.working, world, pars)
end

function go_to_leisure!(agent, world, pars, t)
    @assert agent.activity == Activity.prepare_leisure
    
    agent.t_next_act = t + rand(pars.t_leisure[1]:pars.t_leisure[2])
    travel!(agent, rand(agent.fun), Activity.leisure, world, pars)
end

function go_home!(agent, world, pars, plan = Activity.home)
    @assert agent.activity == Activity.working || agent.activity == Activity.leisure

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


function covid_experience!(agent, world, pars)
    delta = - agent.cov_experience * pars.exp_decay 
    
    if sick(agent)
        delta += (1.0 - agent.cov_experience) * pars.exp_self_weight
    end
    
    ps = length(agent.family) == 0 ? 0.0 : count(sick, agent.family) / length(agent.family)
    delta += (1.0 - agent.cov_experience) * pars.exp_family_weight * ps

    ps = count(sick, agent.friends) / length(agent.friends)
    delta += (1.0 - agent.cov_experience) * pars.exp_friends_weight * ps
    
    agent.cov_experience = max(min(agent.cov_experience + delta, 1.0), 0.0)
end


# done globally for now
# TODO take into account viral load
function do_infections!(place, world, pars)
    inf = @static_var Agent[]
    susc = @static_var Agent[]
    empty!(inf)
    empty!(susc)
    
    for a in place.present
        if infectious(a)
            push!(inf, a)
        elseif update_disease!(a)
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
        ai = rand(inf)
        as = rand(susc)
        mitigation = world.require_masks && rand() > ai.obstinacy ?
            pars.masks_effect : 0.0
            
        if encounter!(ai, as, world.ief, mitigation, pars)
            place.n_infections += 1
        end
    end
    nothing
end


function check_policies!(world, pars)
    prop_inf = count(sick, world.pop) / length(world.pop)
    
    if prop_inf > pars.alarm_inc_thresh
        world.alarm += (1.0 - world.alarm) * pars.alarm_inc_d
    end
    if prop_inf < pars.alarm_dec_thresh
        world.alarm -= world.alarm * pars.alarm_dec_d
    end
    
    world.require_masks = world.alarm > pars.masks_trigger
    world.lockdown = world.alarm > pars.lockdown_trigger
    world.isolation = world.alarm > pars.isolate_trigger
end
