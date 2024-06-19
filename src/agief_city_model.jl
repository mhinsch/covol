using CompositeStructs

using IEFModel


@composite @kwdef mutable struct Agent
    CityAgent{Agent}...
    IEFAgent...
end


Agent(home, work, schedule) = Agent(;home, work, schedule)


const Place = PlaceG{Agent}

const Nowhere = Place(PlaceT.nowhere, Pos(-1, -1), [], 0)

const Transport = TransportG{Place}


mutable struct AGIEFModel
    world :: World{Place, Transport, Agent}
    # overall week
    week :: InStructst
    # day of the week
    day :: Int
    # time of day in minutes
    time :: Int
    ief :: IEF
end


function setup_ief!(model, pars)
    model.ief = IEFModel.setup_ief(pars)
end


function create_agent(world, home, age, pars)
    work = age<18 ? get_rand_school(world) : get_rand_work(world)
    schedule = get_rand_schedule(world)
    
    agent = Agent(home, work, schedule)
    add_agent!(agent.home, agent)
    
    setup_agent!(agent, pars)
    
    agent.virus = NoVirus
    
    agent
end


function initial_infected!(world, ief, pars)
    if pars.mixed_ini_inf
        for i in 1:pars.n_infected
            while true
                inf = rand(world.pop)
                if !infected(inf) 
                    initial_infect!(inf, pars)
                    break
                end
            end
        end
    else
        pat0 = rand(world.pop)
        initial_infect!(pat0, pars)
        for i in 1:(pars.n_infected-1)
            while true
                inf = rand(world.pop)
                if !infected(inf) 
                    infect!(inf, pat0.virus, ief, pars)
                    break
                end
            end
        end
    end
end


function setup_model(pars)
    world = create_world(pars)
    setup_transport!(world, pars)
    setup_flexible_schedules!(world, pars)
    setup_ief!(world, pars)
    if pars.pop_file == ""
        create_synth_agents!(world, pop_size(pars), pars)
        setup_family_in_house!(world, pars)
    else
        pf = open(pars.pop_file, "r")
        agents, houses = load_pop_from_file(pf)
        setup_pre_pop!(world, agents, houses, pars)
    end
    setup_rand_friends!(world, pars)
    initial_infected!(world, pars)
    Model(world, 0, 1, 0)
end

    
function step!(model, pars)
    model.time += pars.timestep

    if model.time / 60 >= 24
        model.day += 1
        if model.day == 8
            model.day = 1
            model.week += 1
        end
        model.time = 0
    end

    world = model.world
    
    #println("activity")
    for agent in world.pop
        activity!(agent, world, model.day, model.time, pars)
    end

    #println("disease")
    #if model.time % pars.dt_disease == 0
        for agent in world.pop
            update_disease!(agent, world, pars)
        end
    #end

    #println("infection")
    for house in world.map
        do_infections!(house, world, pars) do inf, susc, mit
            encounter!(inf, susc, model.ief, mit, pars)
        end
    end

    #println("infection II")
    for transp in world.transports, car in transp.cars
        do_infections!(car, world, pars) do inf, susc, mit
            encounter!(inf, susc, model.ief, mit, pars)
        end    
    end
    
    #println("experience")
    if model.time % pars.dt_exp == 0
        for agent in world.pop
            covid_experience!(agent, world, pars)
        end
    end
    
    #println("policies")
    if model.time % pars.policy_check_dt == 0
    	check_policies!(world, pars)
	end
end
