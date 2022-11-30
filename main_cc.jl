include("main_util.jl")
include("cov_city.jl")
include("analysis_cc.jl")

using Random

const (pars, iefpars), args = load_parameters(ARGS, (Params, IEFParams))

Random.seed!(pars.seed)

const model = setup_model(pars, iefpars)

function run(model, pars, iefpars)
    for i in 1:pars.n_steps
        step!(model, pars, iefpars)
        data = observe(Data, model.world)
        ticker(model, data)
    end
end

if !isinteractive()
    run(model, pars, iefpars)
end
