using Distributions

function get_rnd_empty_house(houses)
    while true
        house = rand(houses)
        if isnowhere(house)
            return house
        end
    end
end
    

function create_world(pars)
    map = [ Place(PlaceT.nowhere, Pos(x, y), []) for x in 1:pars.x_size, y in 1:pars.y_size ]

    houses = Vector{Vector{Place}}()

    for i in 1:n_instances(PlaceT.T)-1
        push!(houses, Vector{Place}())
    end

    for i in 1:pars.n_schools
        h = get_rnd_empty_house(map)
        h.type = PlaceT.school
        push!(houses[Int(PlaceT.school)], h)
    end

    for i in 1:pars.n_hospitals
        h = get_rnd_empty_house(map)
        h.type = PlaceT.hospital
        push!(houses[Int(PlaceT.hospital)], h)
    end

    for i in 1:pars.n_smarkets
        h = get_rnd_empty_house(map)
        h.type = PlaceT.supermarket
        push!(houses[Int(PlaceT.supermarket)], h)
    end

    for i in 1:pars.n_commercial
        h = get_rnd_empty_house(map)
        h.type = PlaceT.work
        push!(houses[Int(PlaceT.work)], h)
    end

    for i in 1:pars.n_leisure
        h = get_rnd_empty_house(map)
        h.type = PlaceT.leisure
        push!(houses[Int(PlaceT.leisure)], h)
    end

    # everything else is residential
    for h in map
        if h.type == PlaceT.nowhere
            h.type = PlaceT.residential
        end
        push!(houses[Int(PlaceT.residential)], h)
    end

    t_cache = [ Transport[] for x in 1:pars.x_size, y in 1:pars.y_size ]

    World(map, houses, [], [], t_cache, [], IEF([], []))
end


# This is super inefficient ATM as there is substantial overlap between
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
            push!(t.cars, Place(PlaceT.transport, Pos(0, 0), []))
        end
        push!(world.transports, t)

        bresenham(t.p1.pos.x, t.p1.pos.y, t.p2.pos.x, t.p2.pos.y) do x, y
            # very inefficient
            cache_transport!(t, world.t_cache, x, y,  pars)
        end
    end
    nothing
end


function setup_schedules!(world, pars)
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


function setup_flexible_schedules!(world, pars)
    workday_home = [
        6*60 => decide_home2work 
       ]
    workday_working = [
        10*60 => decide_work2home
       ]

    sched = Schedule(FlexibleDaySched, 6)

    for day in 1:5
        sched.at[day, Int(Activity.home)] = workday_home
        sched.at[day, Int(Activity.working)] = workday_working
    end

    push!(world.schedules, sched)
end


function setup_ief!(world, iefpars)
    world.ief = IEFModel.setup_ief(iefpars)
end

function create_agents!(world, pars)
    # simplistic home, work
    # TODO family size distribution
    # TODO non-residential homes (e.g. care homes)
    # TODO work close to home
    # TODO age structure
    # TODO job type
    # TODO soc status
    for i in 1:pars.n_agents
        home = rand(world.houses[Int(PlaceT.residential)])
        work = rand(world.houses[Int(PlaceT.work)])
        agent = Agent(home, work, rand(world.schedules))
        add_agent!(home, agent)
        
        push!(world.pop, agent)
    end

    # TODO shops, fun
end


function setup_social!(world, pars)
    # simplistic family setup
    for home in world.houses[Int(PlaceT.residential)]
        for a1 in home.present, a2 in home.present
            push!(a1.family, a2)
        end
    end

    # TODO friends
end


function initial_infected!(world, pars)
    for i in 1:pars.n_infected
        inf = rand(world.pop)
        inf.immune.status = IStatus.infected
        inf.virus.ief_0 = 1.0
        inf.virus.e_ief = 1.0
    end
end


function setup_model(pars, iefpars)
    world = create_world(pars)
    setup_transport!(world, pars)
    setup_schedules!(world, pars)
    setup_ief!(world, iefpars)
    create_agents!(world, pars)
    setup_social!(world, pars)
    initial_infected!(world, pars)
    Model(world, 0, 1, 0)
end
