using Distributions
using Erdos: erdos_renyi, edges, src, dst

function get_rnd_empty_house(houses)
    while true
        house = rand(houses)
        if isnowhere(house)
            return house
        end
    end
end


function create_square_map(PLACE, pars)
    map = [ PLACE(PlaceT.nowhere, Pos(x, y)) for x in 1:pars.x_size, y in 1:pars.y_size ]
end


n_houses(pars) = pars.x_size * pars.y_size * (1.0 - pars.prop_leisure) - 
    pars.n_hospitals - pars.n_smarkets 
        
space_per_person(pars) = 1/pars.ratio_pop_dwellings + pars.prop_children * 1/pars.class_size +
    (1-pars.prop_children) * 1/pars.workplace_size
    
pop_size(pars) = floor(Int, n_houses(pars)/space_per_person(pars) * 0.95)
    
n_children(pars) = floor(Int, pop_size(pars) * pars.prop_children)

n_schools(pars) = floor(Int, n_children(pars) / pars.class_size * 1.05)

n_commercial(pars) = floor(Int, (pop_size(pars) - n_children(pars)) / pars.workplace_size)

n_leisure(pars) = floor(Int, n_houses(pars) * pars.prop_leisure)

n_residential(pars) = n_houses(pars) - n_schools(pars) - pars.n_hospitals - pars.n_smarkets -
    n_commercial(pars) - n_leisure(pars)
    

function setup_world!(world, pars)
    world.map = create_square_map(eltype(world.map), pars)
    
    for i in 1:n_instances(PlaceT.T)-1
        push!(world.houses, Vector{Place}())
    end
    
    for i in 1:n_schools(pars)
        h = get_rnd_empty_house(world.map)
        h.type = PlaceT.school
        push!(world.houses[Int(PlaceT.school)], h)
    end

    for i in 1:pars.n_hospitals
        h = get_rnd_empty_house(world.map)
        h.type = PlaceT.hospital
        push!(world.houses[Int(PlaceT.hospital)], h)
    end

    for i in 1:pars.n_smarkets
        h = get_rnd_empty_house(world.map)
        h.type = PlaceT.supermarket
        push!(world.houses[Int(PlaceT.supermarket)], h)
    end

    for i in 1:n_commercial(pars)
        h = get_rnd_empty_house(world.map)
        h.type = PlaceT.work
        push!(world.houses[Int(PlaceT.work)], h)
    end

    for i in 1:n_leisure(pars)
        h = get_rnd_empty_house(world.map)
        h.type = PlaceT.leisure
        push!(world.houses[Int(PlaceT.leisure)], h)
    end

    # everything else is residential
    for h in world.map
        if h.type == PlaceT.nowhere
            h.type = PlaceT.residential
        end
        push!(world.houses[Int(PlaceT.residential)], h)
    end

    world.t_cache = [ eltype(world.transports)[] for x in 1:pars.x_size, y in 1:pars.y_size ]
    
    nothing
end


function load_pop_from_file(io)
    #skip header 
    readline(io)
    
    # house id => agents ids
    houses = Dict{Int128, Vector{Int128}}()
    # agent id => (age, family ids)
    agents = Dict{Int128, Tuple{Float64, Vector{Int128}}}()
   
    for line in eachline(io)
        fs = split(line)
        pid = parse(Int128, fs[1])
        hid = parse(Int128, fs[2])
        age = parse(Rational{Int}, fs[3]) |> Float64
        father = parse(Int128, fs[6])
        mother = parse(Int128, fs[7])
        partner = parse(Int128, fs[8])
        children = split(replace(fs[10], "("=>"", ")"=>""), ",")
        family = isempty(children) || children[1]=="" ? Int128[] : parse.(Int128, children)
        if father != 0
            push!(family, father)
        end
        if mother != 0
            push!(family, mother)
        end
        if partner != 0
            push!(family, partner)
        end
        agents[pid] = age, family
        h = get!(()->Vector{Int128}(), houses, hid)
        push!(h, pid)
    end
    
    agents, values(houses) |> collect 
end
        

# This is superpop_size(pars)inefficient ATM as there is substantial overlap between
# subsequent points (see setup_transport).
# However, this is called only once during setup, so we can probably live with that.
function cache_transport!(tp, cache, atx, aty, pars)
    xmi = floor(Int, max(1, atx - pars.walk_dist))
    xma = ceil(Int, min(pars.x_size, atx + pars.walk_dist))
    ymi = floor(Int, max(1, aty - pars.walk_dist))
    yma = ceil(Int, min(pars.y_size, aty + pars.walk_dist))

    d = pars.walk_dist ^ 2

    for x in xmi:xma, y in ymi:yma
        if sq_dist(x, y, atx, aty) > d
            continue
        end
        if ! (tp in cache[x, y])
            push!(cache[x, y], tp)
        end
    end
end


function setup_transport!(world, pars)
    for i in 1:pars.n_transport
        t = Transport(rand(world.map), rand(world.map), [], pars.car_cap)
        for c in 1:pars.n_cars
            push!(t.cars, Place(PlaceT.transport, Pos(0, 0)))
        end
        push!(world.transports, t)

        bresenham(t.p1.pos.x, t.p1.pos.y, t.p2.pos.x, t.p2.pos.y) do x, y
            # very inefficient
            cache_transport!(t, world.t_cache, x, y,  pars)
        end
    end
    nothing
end


# deprecated
#=function setup_schedules!(world, pars)
    SI = SchedItem
    workday_home = [
        6*60 => SI(0.1 => go_to_work!), 
        7*60 => SI(0.2 => go_to_work!),
        8*60 => SI(0.5 => go_to_work!),
        9*60 => SI(0.9 => go_to_work!),
        11*60 => SI(0.0 => go_to_work!)
       ]
    workday_working = [
        16*60 => SI(0.1 => go_home!), 
        17*60 => SI(0.3 => go_home!),
        18*60 => SI(0.9 => go_home!),
        19*60 => SI(1.0 => go_home!)
       ]

    sched = Schedule(6)

    for day in 1:5
        sched.at[day, Int(Activity.home)] = workday_home
        sched.at[day, Int(Activity.working)] = workday_working
    end

    push!(world.schedules, sched)
end
=#

function setup_flexible_schedules!(world, pars)
    sched = Schedule{FlexibleDaySched}(n_instances(Activity.T)-1) # none has no schedules

    for day in 1:5
        sched.at[day, Int(Activity.home)] 			= [ 7*60 => decide_home2work  ]
        sched.at[day, Int(Activity.prepare_work)] 	= [ 8*60 => check_go_to_work ]
        sched.at[day, Int(Activity.working)] 		= [ 16*60 => decide_work2home ]
    end
    
    for day in 6:7
        sched.at[day, Int(Activity.home)] 			= [ 10*60 => decide_home2leisure ]
        sched.at[day, Int(Activity.prepare_leisure)]= [ 11*60 => check_go_to_leisure ]
        sched.at[day, Int(Activity.leisure)] 		= [ 11*60 => decide_leisure2home ]
    end
    
    # decide on stay home each day
    for day in 1:7
        sched.at[day, Int(Activity.stay_home)] =  [
            24*60-(pars.timestep+1) => ((a, w, p, t) -> a.activity = Activity.home)
            ]    
    end

    push!(world.schedules, sched)
end


function create_agent_work(world, age, pars)
    work = age<18 ? get_rand_school(world) : get_rand_work(world)
    schedule = get_rand_schedule(world)
    
    work, schedule
end
    

function setup_agent!(world, agent, pars)
    add_agent!(agent.home, agent)
    push!(world.pop, agent)
    
    agent.risk = rand() < pars.p_at_risk ? 
        rand() * (pars.risk_range[2]-pars.risk_range[1]) + pars.risk_range[1] :
        0.0
        
    agent.recklessness = rand() * (pars.reck_range[2]-pars.reck_range[1]) + pars.reck_range[1]
    agent.obstinacy = rand() * (pars.obst_range[2]-pars.obst_range[1]) + pars.obst_range[1]
    
    for i in 1:pars.n_leisure_pp
        push!(agent.fun, rand(world.houses[Int(PlaceT.leisure)]))
    end
    
    nothing
end


function create_synth_agents!(createf, world, n_agents, pars)
    # simplistic home, work
    # TODO family size distribution
    # TODO non-residential homes (e.g. care homes)
    # TODO work close to home
    # TODO age structure
    # TODO job type
    # TODO soc status
    println("creating $n_agents agents")
    for i in 1:n_agents
        home = rand(world.houses[Int(PlaceT.residential)])
        createf(world, home, rand() < pars.prop_children ? rand(1:18) : rand(19:80), pars)
    end
    # TODO shops 
end


function setup_pre_pop!(createf, world, agents, houses, pars)
    res_houses = world.houses[Int(PlaceT.residential)]
    rnd_indices = 1:length(res_houses) |> collect |> shuffle
    
    n_households = min(length(houses), length(res_houses))
    
    agids_by_obj = Dict{Agent, Int128}()
    ags_by_id = Dict{Int128, Agent}()
    # load agents by household, so that we can simply stop when
    # all houses are full
    for i in 1:n_households
        residents = houses[i]
        house = res_houses[rnd_indices[i]]
        for id in residents
            age = agents[id][1]
            agent = createf(world, house, age, pars)
            agids_by_obj[agent] = id
            ags_by_id[id] = agent
        end
    end
    
    # now that all agents exist we can assign families
    for agent in world.pop
        id = agids_by_obj[agent]
        family = agents[id][2]
        for fid in family
            fagent = get(ags_by_id, fid, nothing)
            # we might have run out of houses, so not all agents might have been loaded
            if fagent == nothing
                continue
            end
            
            push!(agent.family, fagent)
        end
    end
end


function setup_family_in_house!(world, pars)
    # simplistic family setup
    for home in world.houses[Int(PlaceT.residential)]
        for a1 in home.present, a2 in home.present
            push!(a1.family, a2)
        end
    end
end


function setup_rand_friends!(world, pars)
    n_a = length(world.pop)
    n_conn = rand(Binomial(n_a*(n_a-1)÷2, pars.mean_n_friends/n_a))
   
    for i in 1:n_conn
        while true
            a = rand(world.pop)
            b = rand(world.pop)
            if a!=b && !(a in b.family) && !(a in b.friends)
                push!(a.friends, b)
                push!(b.friends, a)
                break
            end
        end
    end
    
    #println("#friends: ", sum(a -> length(a.friends), world.pop)/length(world.pop))
end



