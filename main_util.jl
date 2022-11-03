
include("src/util.jl")
include("src/schedule.jl")
include("src/agents.jl")
include("src/model.jl")
include("src/setup.jl")
include("src/params.jl")
include("src/update.jl")


function setup_model(pars)
    world = create_world(pars)
    setup_transport!(world, pars)
    setup_schedules!(world, pars)
    create_agents!(world, pars)
    setup_social!(world, pars)
    Model(world, 1, 0)
end
