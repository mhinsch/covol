include("main_util.jl")
include("analysis.jl")

using Random

const pars, args = load_parameters(ARGS)

Random.seed!(pars.seed)

const model = setup_model(pars)

function run(model, pars)
    for i in 1:pars.n_steps
        step!(model, pars)
        data = observe(Data, model.world)
        println("day: ", model.day, "\ttime: ", model.time/60, "\t", data.n_commute.n)
    end
end

if !isinteractive()
    run(model, pars)
end
