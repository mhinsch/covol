using CompositeStructs


include("util.jl")
include("varfac/infection.jl")
include("varfac/immune.jl")
include("varfac/virus.jl")
include("varfac/agents.jl")
include("varfac/disease.jl")
include("varfac/params.jl")
include("city_world/agents.jl")
include("city_world/model.jl")
include("city_world/setup.jl")
include("city_world/params.jl")
include("city_world/activity.jl")


@composite @kwdef mutable struct AllParams
    Params...
    VarfacParams...
end


@composite @kwdef mutable struct Agent
    CityAgent{Agent}...
    VarfacAgent...
end

Agent(home, work, schedule) = Agent(;home, work, schedule)


const Place = PlaceG{Agent}

const Nowhere = Place(PlaceT.nowhere, Pos(-1, -1), [], 0)

const Transport = TransportG{Place}


mutable struct VarfacModel
    world :: World{Place, Transport, Agent}
    # overall week
    week :: Int
    # day of the week
    day :: Int
    # time of day in minutes
    time :: Int
end


function create_agent(world, home, age, pars)
    work, schedule = create_agent_work(world, age, pars)
    agent = Agent(home, work, schedule)
    setup_agent!(world, agent, pars)
    
    agent
end


function initial_infected!(world, pars)
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
                    infect!(inf, pat0.viruses[1], pars)
                    break
                end
            end
        end
    end
end


function setup_model(pars)
    world = World{Place, Transport, Agent}([;;], [], [], [], [;;], [], 0.0, false, false, false) 
    setup_world!(world, pars)
    setup_transport!(world, pars)
    setup_flexible_schedules!(world, pars)
    if pars.pop_file == ""
        create_synth_agents!(create_agent, world, pop_size(pars), pars)
        setup_family_in_house!(world, pars)
    else
        pf = open(pars.pop_file, "r")
        agents, houses = load_pop_from_file(pf)
        setup_pre_pop!(create_agent, world, agents, houses, pars)
    end
    setup_rand_friends!(world, pars)
    model = VarfacModel(world, 0, 1, 0)
    initial_infected!(world, pars)
    
    model
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
            encounter!(inf, susc, mit, pars)
        end
    end

    #println("infection II")
    for transp in world.transports, car in transp.cars
        do_infections!(car, world, pars) do inf, susc, mit
            encounter!(inf, susc, mit, pars)
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
