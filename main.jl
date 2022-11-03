include("main_util.jl")

using Random

const pars, args = load_parameters(ARGS)

Random.seed!(pars.seed)

const model = setup_model(pars)

for i in 1:pars.n_steps
    step!(model, pars)
    if model.day == 1 && model.time == 0
        print(".")
    end
end
